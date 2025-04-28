# iam_user_with_s3_full_access/main.tf
resource "aws_iam_user" "s3_user" {
  name = var.user_name
  tags = var.tags
}

resource "aws_iam_access_key" "s3_access_key" {
  user = aws_iam_user.s3_user.name
}

resource "aws_iam_user_policy" "s3_full_access_policy" {
  name   = "${aws_iam_user.s3_user.name}-s3-full-access"
  user   = aws_iam_user.s3_user.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "s3:*",
        Resource = "arn:aws:s3:::*",
      },
    ]
  })
}

resource "aws_iam_role" "ec2_role" {
  name_prefix = "ec2-app-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "ec2_policy" {
  name_prefix = "ec2-app-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name_prefix = "ec2-app-profile-"
  role        = aws_iam_role.ec2_role.name
}


