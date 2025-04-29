# AWS Multi-Region Disaster Recovery Infrastructure

## Project Overview

This Terraform project implements a disaster recovery (DR) infrastructure on AWS across two regions, consisting of a primary region and a failover region. The infrastructure includes high availability, automated failover mechanisms, and data replication strategies.

## Architecture Components

### Primary Region
- VPC with public and private subnets
- Application Load Balancer (ALB)
- Auto Scaling Group (ASG) with EC2 instances
- RDS PostgreSQL database
- S3 bucket for static content
- Secrets Manager for sensitive data
- Security Groups
- Route53 DNS configuration

### Failover Region
- Mirrored VPC infrastructure
- Standby ALB and ASG
- RDS Read Replica
- Replicated S3 bucket
- Lambda function for failover orchestration
- CloudWatch alarms
- SNS notifications

## Prerequisites

1. AWS Account with appropriate permissions
2. Terraform (version 1.0.0 or higher)
3. AWS CLI configured with appropriate credentials
4. Domain name registered in Route53
5. SSL certificates in AWS Certificate Manager (in both regions)

## Required Variables

Create a `terraform.tfvars` file with the following variables:

```hcl
primary-azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
failover-azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
db_username = "your_db_username"
db_password = "your_db_password"
db_name = "your_db_name"
primary_certificate_arn = "arn:aws:acm:region:account:certificate/xxx"
failover_certificate_arn = "arn:aws:acm:region:account:certificate/xxx"
domain_name = "your-domain.com"
iam_user_name = "s3-replication-user"
application_port = 3000
primary_s3_region = "eu-west-1"
failover_s3_region = "us-east-1"
```

## Deployment Instructions

1. Initialize Terraform:
```bash
terraform init
```

2. Review the deployment plan:
```bash
terraform plan
```

3. Apply the configuration:
```bash
terraform apply
```

4. To destroy the infrastructure:
```bash
terraform destroy
```

## Infrastructure Details

### Networking
- Primary VPC: 10.0.0.0/16 (eu-west-1)
- Failover VPC: 10.0.0.0/16 (us-east-1)
- Three public and private subnets in each region

### Security
- ALB Security Group: Allows inbound HTTP/HTTPS
- EC2 Security Group: Allows traffic from ALB
- RDS Security Group: Allows traffic from EC2 instances
- IAM roles and policies for EC2 instances and S3 replication

### Database
- Primary: RDS PostgreSQL instance
- Failover: Read replica with promotion capability
- Automated backup enabled

### Application Layer
- Ubuntu-based EC2 instances
- Docker containers running the application
- Auto Scaling Group for high availability
- Application Load Balancer for traffic distribution

### Storage
- Cross-region S3 bucket replication
- Versioning enabled on both buckets

### Monitoring and Failover
- Route53 health checks
- CloudWatch alarms
- SNS notifications
- Lambda-based failover automation

## Failover Process

1. Route53 health checks monitor the primary region
2. When primary region fails, CloudWatch alarm triggers
3. SNS notification is sent to Lambda function
4. Lambda function:
   - Promotes RDS read replica
   - Updates failover region ASG capacity
   - Routes traffic to failover region

## Notes

- All sensitive information is stored in AWS Secrets Manager
- S3 buckets are configured with cross-region replication
- SSL/TLS termination happens at the ALB level
- Regular backups are maintained for the database
- Proper IAM roles and policies are implemented for security

## Limitations

- Manual intervention might be required for specific failback scenarios
- Cross-region latency should be considered
- Cost implications of maintaining redundant infrastructure
- Region-specific AMI IDs need to be updated

## Best Practices

1. Regularly test the failover mechanism
2. Monitor costs across both regions
3. Keep AMIs updated
4. Review security group rules periodically
5. Maintain proper documentation of any manual procedures

## Support

For issues and feature requests, please open an issue in the repository.