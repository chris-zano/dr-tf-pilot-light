terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "primary_health_alarm" {
  alarm_name          = var.alarm_name
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1

  dimensions = {
    HealthCheckId = var.health_check_id
  }

  alarm_description = "Alarm when the primary ALB becomes unhealthy"
  alarm_actions     = [var.sns_topic_arn]
}
