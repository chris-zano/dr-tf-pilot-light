variable "private_subnets" {
    description = "List of private subnet CIDR blocks"
    type = list(string)
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
  sensitive = true
}

variable "db_name" {
  type = string
  default = "lampdb"
}

variable "db_security_group" {
  type = list(string)
  description = "Security group for database"
}