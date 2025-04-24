variable "private_subnets" {
  type = list(string)
}

variable "source_db_arn" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "db_security_group" {
  type = list(string)
}