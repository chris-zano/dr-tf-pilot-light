output "db_endpoint" {
  value = aws_db_instance.replica.endpoint
}
output "db_hostname" {
  value = aws_db_instance.replica.address
}

output "db_port" {
  value = aws_db_instance.replica.port
}