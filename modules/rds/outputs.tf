output "db_instance_class" {
  value = aws_db_instance.postgres.instance_class
}

output "source_db_arn" {
  value = aws_db_instance.postgres.arn
}

output "db_endpoint" {
  value = aws_db_instance.postgres.endpoint
}