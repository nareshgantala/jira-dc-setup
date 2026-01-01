resource "aws_db_instance" "jira_db" {
  identifier             = "jira-dc-db"
  engine                 = "postgres"
  engine_version         = "13"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20

  db_name                = "jiradb"
  username               = "jirauser"
  password               = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.jira_db_subnet.name
  vpc_security_group_ids = [aws_security_group.jira_sg.id]

  publicly_accessible    = false
  skip_final_snapshot    = true
}

