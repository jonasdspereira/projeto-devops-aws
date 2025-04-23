provider "aws" {
  region = "us-east-1"  # Ajuste para sua região
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "squad5-desafio-state"  # Altere para um nome único
  
  # Impedir a exclusão acidental do bucket
  force_destroy = false
  
  tags = {
    Name        = "Terraform State"
    Environment = "Global"
    Project     = "DevOps AWS"
  }
}

# Habilitar versionamento do bucket
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Habilitar criptografia por padrão
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloquear acesso público ao bucket
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Criar tabela DynamoDB para lock state
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-state-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock"
    Environment = "Global"
    Project     = "DevOps AWS"
  }
}

# Outputs para usar depois
output "state_bucket_name" {
  value = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_state_lock.name
} 