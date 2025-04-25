variable "primary-azs" {
  type        = list(string)
  description = "primary-azs"
}

variable "failover-azs" {
  type        = list(string)
  description = "failover-azs"
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type    = string
  default = "lampdb"
}

variable "primary_certificate_arn" {
  type = string
}
variable "failover_certificate_arn" {
  type = string
}

variable "db_port" {
  type    = number
  default = 5432
}

variable "domain_name" {
  type = string
}