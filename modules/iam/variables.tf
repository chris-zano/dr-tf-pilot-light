# iam_user_with_s3_full_access/variables.tf
variable "user_name" {
  type        = string
  description = "The name of the IAM user to create."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to apply to the IAM user."
}