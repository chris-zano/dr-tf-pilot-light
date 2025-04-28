terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}


resource "aws_lb" "main" {
  name               = "example-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb_security_group_ids
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "main" {
  name     = "example-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
  target_type = "instance"
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


resource "aws_launch_template" "main" {
  name_prefix   = "application-lt-"
  image_id      = var.aws_ami_id
  instance_type = "t3.micro"

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = var.ec2_security_group_ids
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash

    set -e

    # Update and upgrade system packages
    apt update -y
    apt upgrade -y

    # Install AWS CLI if not present
    if ! command -v aws &> /dev/null; then
      apt install unzip
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      ./aws/install
      echo "Installation complete"
    fi

    # Install jq for parsing JSON
    apt install -y jq  

    secret_json=$(aws secretsmanager get-secret-value --secret-id "${var.secret_manager_name}" --query SecretString --output text --region ${var.secret_manager_region})

    # Parse the JSON secret and export environment variables
    export AWS_ACCESS_KEY_ID=$(echo "$secret_json" | jq -r '.access_key_id')
    export AWS_SECRET_ACCESS_KEY=$(echo "$secret_json" | jq -r '.secret_access_key')
    export AWS_REGION=$(echo "$secret_json" | jq -r '.s3_region')
    export S3_BUCKET_NAME=$(echo "$secret_json" | jq -r '.s3_bucket_name')
    export DB_USER=$(echo "$secret_json" | jq -r '.db_username')
    export DB_HOST=$(echo "$secret_json" | jq -r '.db_host')
    export DB_NAME=$(echo "$secret_json" | jq -r '.db_name')
    export DB_PASSWORD=$(echo "$secret_json" | jq -r '.db_password')
    export DB_PORT=$(echo "$secret_json" | jq -r '.db_port')
    export PORT=$(echo "$secret_json" | jq -r '.port')

    echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"
    echo "AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY"
    echo "AWS_REGION: $AWS_REGION"
    echo "S3_BUCKET_NAME: $S3_BUCKET_NAME"
    echo "DB_USER: $DB_USER"
    echo "DB_HOST: $DB_HOST"
    echo "DB_NAME: $DB_NAME"
    echo "DB_PASSWORD: $DB_PASSWORD"
    echo "DB_PORT: $DB_PORT"
    echo "PORT: $PORT"

    # Install Docker
    if ! command -v docker &> /dev/null; then
      curl -fsSL https://get.docker.com -o get-docker.sh
      sh get-docker.sh
      rm get-docker.sh
    fi

    # Start and enable Docker service
    systemctl start docker
    systemctl enable docker

    # Add current user to the docker group (non-root Docker use)
    usermod -aG docker ubuntu
    
    newgrp docker

    echo "Pulling the docker image [ chrisncs/simple-gallery:latest ]"
    docker pull chrisncs/simple-gallery:latest

    docker run -d \
      -p 80:"$PORT" \
      -e PORT="$PORT" \
      -e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
      -e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
      -e AWS_REGION="$AWS_REGION" \
      -e S3_BUCKET_NAME="$S3_BUCKET_NAME" \
      -e DB_USER="$DB_USER" \
      -e DB_HOST="$DB_HOST" \
      -e DB_NAME="$DB_NAME" \
      -e DB_PASSWORD="$DB_PASSWORD" \
      -e DB_PORT="$DB_PORT" \
      chrisncs/simple-gallery:latest

    echo "running docker ps"
    docker ps
  EOF
  )
}


# ---------------------------
# Auto Scaling Group
# ---------------------------
resource "aws_autoscaling_group" "main" {
  name                      = "example-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = [aws_lb_target_group.main.arn]
  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "example-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
