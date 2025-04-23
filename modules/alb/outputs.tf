output "target_group_arn" {
  description = "ARN do target group"
  value       = aws_lb_target_group.web.arn
}

output "dns_name" {
  description = "DNS name do Application Load Balancer"
  value       = aws_lb.web.dns_name
}

output "security_group_id" {
  description = "ID do security group do ALB"
  value       = aws_security_group.alb.id
}

output "alb_arn_suffix" {
  description = "Suffix do ARN do ALB para métricas do CloudWatch"
  value       = aws_lb.web.arn_suffix
} 