variable "key_name" {
  description = "EC2 key pair name"
}

variable "db_password" {
  description = "RDS password"
  sensitive   = true
}
