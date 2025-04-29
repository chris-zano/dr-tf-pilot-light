output "lambda_function_arn" {
  value = aws_lambda_function.promote_rds_and_update_asg.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.promote_rds_and_update_asg.function_name
}