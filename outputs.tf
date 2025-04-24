output "primary_vpc_id" {
  description = "VPC ID of the primary region"
  value       = module.primary-vpc.vpc_id
}

output "failover_vpc_id" {
  description = "VPC ID of the failover region"
  value       = module.failover-vpc.vpc_id
}

output "primary_alb_dns_name" {
  description = "DNS name of the ALB in the primary region"
  value       = module.primary-alb-asg.alb_dns_name
}

output "failover_alb_dns_name" {
  description = "DNS name of the ALB in the failover region"
  value       = module.failover-alb-asg.alb_dns_name
}

output "primary_db_endpoint" {
  description = "Primary RDS endpoint"
  value       = module.primary-rds.db_endpoint
}

output "failover_db_endpoint" {
  description = "Failover RDS read replica endpoint"
  value       = module.rds-failover-replica.db_endpoint
}

output "primary_alb_target_group_arn" {
  description = "ARN of the primary region's ALB target group"
  value       = module.primary-alb-asg.target_group_arn
}

output "failover_alb_target_group_arn" {
  description = "ARN of the failover region's ALB target group"
  value       = module.failover-alb-asg.target_group_arn
}

output "primary_launch_template_id" {
  description = "Launch template ID used in the primary region"
  value       = module.primary-alb-asg.launch_template_id
}

output "failover_launch_template_id" {
  description = "Launch template ID used in the failover region"
  value       = module.failover-alb-asg.launch_template_id
}

output "primary_asg_name" {
  description = "Auto Scaling Group name in the primary region"
  value       = module.primary-alb-asg.asg_name
}

output "failover_asg_name" {
  description = "Auto Scaling Group name in the failover region"
  value       = module.failover-alb-asg.asg_name
}
