#!/bin/bash
set -eux

JIRA_VERSION="11.3.0"
JIRA_INSTALLER="atlassian-jira-software-${JIRA_VERSION}-x64.bin"
JIRA_HOME="/var/atlassian/application-data/jira"

# System prep
yum update -y
yum install -y java-17-amazon-corretto wget

# Download Jira
cd /opt
wget https://www.atlassian.com/software/jira/downloads/binary/${JIRA_INSTALLER}
chmod +x ${JIRA_INSTALLER}

# Silent install response
cat <<EOF > /opt/jira-response.varfile
app.install.service\$Boolean=false
sys.languageId=en
sys.installationDir=/opt/atlassian/jira
app.defaultInstallDir=/opt/atlassian/jira
app.installation.type=custom
app.jiraHome=${JIRA_HOME}
executeLauncherAction\$Boolean=false
EOF

# Run installer (NO auto-start)
./${JIRA_INSTALLER} -q -varfile jira-response.varfile

# Identify Jira service user (created by installer)
JIRA_USER=$(ls /home | grep jira | head -n 1)

# Set Jira home explicitly
mkdir -p /opt/atlassian/jira/conf
cat <<EOF > /opt/atlassian/jira/conf/jira-application.properties
jira.home=${JIRA_HOME}
EOF

# Fix permissions
chown -R ${JIRA_USER}:${JIRA_USER} /opt/atlassian
chown -R ${JIRA_USER}:${JIRA_USER} /var/atlassian

# Set JVM memory (CRITICAL)
sed -i 's/^JVM_SUPPORT_RECOMMENDED_ARGS=.*/JVM_SUPPORT_RECOMMENDED_ARGS="-Xms2g -Xmx4g"/' \
  /opt/atlassian/jira/bin/setenv.sh

# Create systemd service
cat <<EOF > /etc/systemd/system/jira.service
[Unit]
Description=Atlassian Jira
After=network.target

[Service]
Type=forking
User=${JIRA_USER}
Group=${JIRA_USER}
Environment="JIRA_HOME=${JIRA_HOME}"
PIDFile=/opt/atlassian/jira/work/catalina.pid
ExecStart=/opt/atlassian/jira/bin/start-jira.sh
ExecStop=/opt/atlassian/jira/bin/stop-jira.sh
TimeoutStartSec=300
TimeoutStopSec=300
Restart=on-failure
SuccessExitStatus=143 0

[Install]
WantedBy=multi-user.target
EOF

# Enable & start Jira
systemctl daemon-reload
systemctl enable jira
systemctl start jira
