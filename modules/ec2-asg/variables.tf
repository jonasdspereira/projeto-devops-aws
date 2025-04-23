variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "public_subnets" {
  description = "Lista de IDs das subnets públicas"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN do target group do ALB"
  type        = string
}

variable "alb_arn_suffix" {
  description = "Suffix do ARN do ALB para métricas do CloudWatch"
  type        = string
}

variable "alb_security_group_id" {
  description = "ID do security group do ALB"
  type        = string
}