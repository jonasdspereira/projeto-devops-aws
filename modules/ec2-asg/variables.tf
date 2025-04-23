variable "vpc_id" {
  description = "ID da VPC onde o ASG será criado"
  type        = string
}

variable "public_subnets" {
  description = "IDs das subnets públicas para o ASG"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN do target group para o ASG"
  type        = string
}

variable "alb_security_group_id" {
  description = "ID do security group do ALB"
  type        = string
}