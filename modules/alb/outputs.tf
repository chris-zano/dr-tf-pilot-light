output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.main.arn
}

output "launch_template_id" {
  value = aws_launch_template.main.id
}

output "asg_name" {
  value = aws_autoscaling_group.main.name
}

output "alb_zone_id" {
  value = aws_lb.main.zone_id
}