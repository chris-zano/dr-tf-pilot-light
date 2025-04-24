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

# create rds replica for failover region

module "rds-failover-replica" {
  source = "./modules/rds_replica"

  providers = {
    aws = aws.failover
  }

  db_instance_class = module.primary-rds.db_instance_class
  db_security_group = [module.failover-sg.db_sg_id]
  private_subnets   = module.failover-vpc.private_subnets
  source_db_arn     = module.primary-rds.source_db_arn
}

module "primary-alb-asg" {
  source = "./modules/alb"
  providers = {
    aws = aws.primary
  }
  aws_ami_id         = "ami-0df368112825f8d8f"
  certificate_arn    = var.primary_certificate_arn
  security_group_ids = [module.primary-sg.alb_sg_id]
  subnet_ids         = module.primary-vpc.public_subnet
  vpc_id             = module.primary-vpc.vpc_id
  db_dbname          = var.db_name
  db_password        = var.db_password
  db_username        = var.db_username
  depends_on         = [module.primary-rds]
  db_endpoint        = module.primary-rds.db_endpoint
  db_port            = var.db_port
  desired_capacity = 1
  max_size = 2
  min_size = 1
}

module "failover-alb-asg" {
  source = "./modules/alb"
  providers = {
    aws = aws.failover
  }
  aws_ami_id         = "ami-03250b0e01c28d196"
  certificate_arn    = var.failover_certificate_arn
  security_group_ids = [module.failover-sg.alb_sg_id]
  subnet_ids         = module.failover-vpc.public_subnet
  vpc_id             = module.failover-vpc.vpc_id
  db_dbname          = var.db_name
  db_password        = var.db_password
  db_username        = var.db_username
  depends_on         = [module.rds-failover-replica]
  db_endpoint        = module.rds-failover-replica.db_endpoint
  db_port            = var.db_port
  desired_capacity = 0
  max_size = 0
  min_size = 0
}