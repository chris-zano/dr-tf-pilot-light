variable "topic_name" {
  type        = string
  description = "SNS topic name"
}

variable "lambda_arn" {
  type        = string
  description = "ARN of the Lambda function to trigger"
}
