output "target_group_arn" {
  description = "ARN do target group"
  value       = aws_lb_target_group.web.arn
}

output "dns_name" {
  description = "DNS name do Application Load Balancer"
  value       = aws_lb.web.dns_name
} 