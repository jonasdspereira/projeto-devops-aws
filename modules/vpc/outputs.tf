output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "IDs das subnets públicas criadas"
  value       = aws_subnet.public[*].id
} 