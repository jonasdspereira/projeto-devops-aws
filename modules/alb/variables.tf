variable "vpc_id" {
  description = "ID da VPC onde o ALB será criado"
  type        = string
}

variable "public_subnets" {
  description = "IDs das subnets públicas para o ALB"
  type        = list(string)
}