# create vpc in primary and failover region

module "primary-vpc" {
  source = "./modules/vpc"
  azs    = var.primary-azs

  providers = {
    aws = aws.primary
  }
}

module "failover-vpc" {
  source = "./modules/vpc"
  azs    = var.failover-azs

  providers = {
    aws = aws.failover
  }
}

# create securty groups in primary and failover region
module "primary-sg" {
  source = "./modules/security_groups"
  vpc_id = module.primary-vpc.vpc_id

  providers = {
    aws = aws.primary
  }
}

module "failover-sg" {
  source = "./modules/security_groups"
  vpc_id = module.failover-vpc.vpc_id

  providers = {
    aws = aws.failover
  }
}

#  create rds for primary region

module "primary-rds" {
  source = "./modules/rds"
  providers = {
    aws = aws.primary
  }

  db_name           = var.db_name
  db_password       = var.db_password
  db_username       = var.db_username
  db_security_group = [module.primary-sg.db_sg_id]
  private_subnets   = module.primary-vpc.private_subnets
}

module "rds-failover-replica" {
  source = "./modules/rds_replica"

  providers = {
    aws = aws.failover
  }

  db_instance_class = module.primary-rds.db_instance_class
  db_security_group = [module.failover-sg.db_sg_id]
  private_subnets   = module.failover-vpc.private_subnets
  source_db_arn     = module.primary-rds.source_db_arn
  depends_on = [ module.primary-rds ]
}

# create s3 bucket
module "s3" {
  source = "./modules/s3"
}

module "iam_s3_full_access" {
  source = "./modules/iam"
  user_name = var.iam_user_name
  tags = {
    Name = "S3 Full Access"
  }
}

# create secrets manager
module "primary-secrets" {
  source = "./modules/secrets_manager"
  providers = {
    aws = aws.primary
  }
  secretmanager_name = "primary-secrets-manager-03"
  access_key_id = module.iam_s3_full_access.access_key_id
  secret_access_key = module.iam_s3_full_access.secret_access_key
  db_host = module.primary-rds.db_hostname
  db_name = var.db_name
  db_password = var.db_password
  db_port = module.primary-rds.db_port
  db_username = var.db_username
  port = var.application_port
  s3_bucket_name = module.s3.bucket_name
  s3_region = var.primary_s3_region
  depends_on = [ module.primary-rds, module.s3, module.iam_s3_full_access ]
}

module "failover-secrets" {
  source = "./modules/secrets_manager"
  providers = {
    aws = aws.failover
  }
  secretmanager_name = "failover-secrets-manager-04"
  access_key_id = module.iam_s3_full_access.access_key_id
  secret_access_key = module.iam_s3_full_access.secret_access_key
  db_host = module.rds-failover-replica.db_hostname
  db_name = var.db_name
  db_password = var.db_password
  db_port = module.rds-failover-replica.db_port
  db_username = var.db_username
  port = var.application_port
  s3_bucket_name = module.s3.replica_bucket_name
  s3_region = var.failover_s3_region
  depends_on = [ module.s3, module.rds-failover-replica, module.iam_s3_full_access ]
}

module "primary-alb-asg" {
  source = "./modules/alb"
  providers = {
    aws = aws.primary
  }
  aws_ami_id             = "ami-0df368112825f8d8f"
  certificate_arn        = var.primary_certificate_arn
  alb_security_group_ids = [module.primary-sg.alb_sg_id]
  ec2_security_group_ids = [module.primary-sg.ec2_sg_id]
  subnet_ids             = module.primary-vpc.public_subnet
  vpc_id                 = module.primary-vpc.vpc_id
  db_host                = module.primary-rds.db_hostname
  db_dbname              = var.db_name
  db_password            = var.db_password
  db_username            = var.db_username
  db_endpoint            = module.primary-rds.db_endpoint
  db_port                = module.primary-rds.db_port
  desired_capacity       = 1
  max_size               = 2
  min_size               = 1
  secret_manager_name = module.primary-secrets.secret_name
  secret_manager_region = var.primary_s3_region
  iam_instance_profile_name = module.iam_s3_full_access.iam_instance_profile_name
  depends_on = [module.primary-secrets]
}

module "failover-alb-asg" {
  source = "./modules/alb"
  providers = {
    aws = aws.failover
  }
  aws_ami_id             = "ami-084568db4383264d4"
  certificate_arn        = var.failover_certificate_arn
  alb_security_group_ids = [module.failover-sg.alb_sg_id]
  ec2_security_group_ids = [module.failover-sg.ec2_sg_id]
  subnet_ids             = module.failover-vpc.public_subnet
  vpc_id                 = module.failover-vpc.vpc_id
  db_host                = module.rds-failover-replica.db_hostname
  db_dbname              = var.db_name
  db_password            = var.db_password
  db_username            = var.db_username
  db_endpoint            = module.rds-failover-replica.db_endpoint
  db_port                = module.rds-failover-replica.db_port
  desired_capacity       = 0
  max_size               = 0
  min_size               = 0
  secret_manager_name = module.failover-secrets.secret_name
  secret_manager_region = var.failover_s3_region
  iam_instance_profile_name = module.iam_s3_full_access.iam_instance_profile_name
  depends_on = [ module.failover-secrets ]
}

module "dns" {
  source = "./modules/route53"

  zone_name             = var.domain_name
  record_name           = "www.${var.domain_name}"
  primary_alb_dns_name  = module.primary-alb-asg.alb_dns_name
  primary_alb_zone_id   = module.primary-alb-asg.alb_zone_id
  failover_alb_dns_name = module.failover-alb-asg.alb_dns_name
  failover_alb_zone_id  = module.failover-alb-asg.alb_zone_id
}