terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

resource "aws_db_subnet_group" "db_subnet" {
  name       = "primary-db-subnet"
  subnet_ids = var.private_subnets
}

resource "aws_db_instance" "postgres" {
  allocated_storage       = 10
  storage_type            = "gp2"
  engine                  = "postgres"
  instance_class          = "db.t3.micro"
  identifier              = "postgres-db"
  username                = var.db_username
  password                = var.db_password
  vpc_security_group_ids  = var.db_security_group
  db_subnet_group_name    = aws_db_subnet_group.db_subnet.name
  db_name                 = var.db_name
  skip_final_snapshot     = true
  apply_immediately       = true
  backup_retention_period = 7
  deletion_protection     = false
}
