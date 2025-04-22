variable "cidr_block" {
  description = "CIDR block para a VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_count" {
  description = "Número de subnets públicas a serem criadas"
  type        = number
  default     = 2
} 