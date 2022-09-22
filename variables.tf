
variable "aws_region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "numbers"
}

variable "contact" {
  default = "doblealberto@outlook.com"
}

variable "db_username" {
  description = "Username for the RDS postgres instance"
}

variable "db_password" {
  description = "Password for the RDS postgres instance"
}




