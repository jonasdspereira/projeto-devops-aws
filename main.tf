module "vpc" {
  source = "./modules/vpc"
  cidr_block = var.vpc_cidr_block
  public_subnet_count = var.public_subnet_count
}

module "alb" {
  source = "./modules/alb"
  vpc_id = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
}

module "ec2_asg" {
  source               = "./modules/ec2-asg"
  vpc_id               = module.vpc.vpc_id
  public_subnets       = module.vpc.public_subnets
  target_group_arn     = module.alb.target_group_arn
  alb_security_group_id = module.alb.security_group_id
}