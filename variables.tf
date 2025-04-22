variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnet_count" {
  default = 2
}

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