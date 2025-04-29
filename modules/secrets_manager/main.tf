terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

resource "aws_secretsmanager_secret" "my_secret" {
  name = var.secretmanager_name
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_secretsmanager_secret_version" "my_secret_version" {
  secret_id     = aws_secretsmanager_secret.my_secret.id
  secret_string = jsonencode({
    access_key_id = var.access_key_id,
    secret_access_key = var.secret_access_key,
    s3_bucket_name = var.s3_bucket_name,
    s3_region = var.s3_region,
    db_username = var.db_username,
    db_host = var.db_host,
    db_password = var.db_password,
    db_name = var.db_name,
    db_port = var.db_port
    port = var.port
  })
  lifecycle {
    prevent_destroy = false
  }
}