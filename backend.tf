terraform {
  backend "s3" {
    bucket         = "squad5-desafio-state"  
    key            = "terraform.tfstate"
    region         = "us-east-1"  
    dynamodb_table = "terraform-state-lock"
  }
} 