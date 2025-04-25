variable "vpc_id" {}
variable "subnet_ids" {
  type = list(string)
}
variable "alb_security_group_ids" {
  type = list(string)
}

variable "ec2_security_group_ids" {
  type = list(string)
}

variable "certificate_arn" {}
variable "aws_ami_id" {}

variable "db_endpoint" {
  type = string
}
variable "db_username" {
  type = string
}
variable "db_port" {
  type = string
}
variable "db_dbname" {
  type = string
}

variable "db_host" {
  type = string
}
variable "db_password" {
  type = string
  sensitive = true
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "desired_capacity" {
  type = number
}