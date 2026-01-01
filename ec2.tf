resource "aws_instance" "jira" {
  ami           = "ami-00ca570c1b6d79f36" # Amazon Linux 3
  instance_type = "t3.large"
  key_name      = var.key_name
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.jira_sg.id]

  user_data = file("user-data.sh")

  root_block_device {
    volume_size = 50
  }

  tags = {
    Name = "jira-dc-node"
  }
}
