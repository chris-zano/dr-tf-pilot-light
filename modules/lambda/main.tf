terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/scripts/function.py"
  output_path = "${path.module}/scripts/lambda_function_payload.zip"
}

# --- IAM policy document allowing Lambda to assume role ---
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# --- IAM role for Lambda ---
resource "aws_iam_role" "lambda_exec_role" {
  name               = "lambda_rds_asg_exec_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# --- IAM policy for required permissions ---
resource "aws_iam_policy" "lambda_permissions" {
  name        = "lambda_rds_asg_policy"
  description = "Allow promoting RDS and updating ASG"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "rds:PromoteReadReplica",
          "autoscaling:UpdateAutoScalingGroup"
        ],
        Resource = "*"
      }
    ]
  })
}

# --- Attach policy to role ---
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_permissions.arn
}

# --- Lambda Function ---
resource "aws_lambda_function" "promote_rds_and_update_asg" {
  function_name = "promote-rds-update-asg"
  handler       = "function.handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_exec_role.arn
  filename      = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  environment {
    variables = {
      REPLICA_IDENTIFIER     = var.replica_instance_name
      ASG_NAME               = var.asg_name
      ASG_DESIRED_CAPACITY   = "1"
      ASG_MIN_SIZE           = "1"
      ASG_MAX_SIZE           = "2"
    }
  }
}