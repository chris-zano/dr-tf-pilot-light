
# get existing hosted zone
data "aws_route53_zone" "selected" {
  name = var.zone_name
  private_zone = false
}

# Create health check for primary ALB
resource "aws_route53_health_check" "primary" {
  fqdn              = var.primary_alb_dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "3"
  request_interval  = "30"

  tags = {
    Name = "primary-alb-health-check"
  }
}

# Create health check for failover ALB
resource "aws_route53_health_check" "failover" {
  fqdn              = var.failover_alb_dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "3"
  request_interval  = "30"

  tags = {
    Name = "failover-alb-health-check"
  }
}

# Create primary record
resource "aws_route53_record" "primary" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.record_name
  type    = "A"

  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier = "primary"
  health_check_id = aws_route53_health_check.primary.id

  alias {
    name                   = var.primary_alb_dns_name
    zone_id                = var.primary_alb_zone_id
    evaluate_target_health = true
  }
}

# Create failover record
resource "aws_route53_record" "failover" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.record_name
  type    = "A"

  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier = "failover"
  health_check_id = aws_route53_health_check.failover.id

  alias {
    name                   = var.failover_alb_dns_name
    zone_id                = var.failover_alb_zone_id
    evaluate_target_health = true
  }
}