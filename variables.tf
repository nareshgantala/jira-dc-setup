variable "key_name" {
  default = "jiradc"
  description = "EC2 key pair name"
}

variable "db_password" {
  description = "RDS password"
  default = "admin1234"
  sensitive   = true
}
