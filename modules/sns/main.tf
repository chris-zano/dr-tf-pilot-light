terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

resource "aws_sns_topic" "failover_alerts" {
  name = var.topic_name
}

resource "aws_sns_topic_subscription" "lambda_sub" {
  topic_arn = aws_sns_topic.failover_alerts.arn
  protocol  = "lambda"
  endpoint  = var.lambda_arn
}
