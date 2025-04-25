variable "source_bucket_name" {
  description = "The name of the primary (source) S3 bucket"
  type        = string
  default = "source-bucket-niico"
}

variable "replica_bucket_name" {
  description = "The name of the failover (replica) S3 bucket"
  type        = string
  default = "replica-bucket-niico"
}