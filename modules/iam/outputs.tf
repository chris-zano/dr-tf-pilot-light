
# iam_user_with_s3_full_access/outputs.tf
output "user_name" {
  description = "The name of the IAM user."
  value       = aws_iam_user.s3_user.name
}

output "access_key_id" {
  description = "The access key ID for the IAM user."
  value       = aws_iam_access_key.s3_access_key.id
  sensitive   = true
}

output "secret_access_key" {
  description = "The secret access key for the IAM user."
  value       = aws_iam_access_key.s3_access_key.secret
  sensitive   = true
}

output "user_arn" {
  description = "The ARN of the IAM user."
  value       = aws_iam_user.s3_user.arn
}

output "iam_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_profile.name
}