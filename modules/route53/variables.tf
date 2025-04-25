variable "zone_name" {
  description = "The name of the hosted zone"
  type        = string
}

variable "record_name" {
  description = "The name of the record"
  type        = string
}

variable "primary_alb_dns_name" {
  description = "The DNS name of the primary ALB"
  type        = string
}

variable "primary_alb_zone_id" {
  description = "The zone ID of the primary ALB"
  type        = string
}

variable "failover_alb_dns_name" {
  description = "The DNS name of the failover ALB"
  type        = string
}

variable "failover_alb_zone_id" {
  description = "The zone ID of the failover ALB"
  type        = string
}