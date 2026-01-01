output "jira_public_ip" {
  value = aws_instance.jira.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.jira_db.endpoint
}
