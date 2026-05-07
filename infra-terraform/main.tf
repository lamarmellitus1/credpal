
# Networking

module "networking" {
  source = "./modules/networking"

  environment              = var.environment
  vpc_cidr                 = var.vpc_cidr
  availability_zones       = var.availability_zones
  enable_nat_gateway       = true
  single_nat_gateway       = var.environment != "production"
  enable_vpc_flow_logs     = true
  flow_logs_retention_days = 30
}





# Security Groups

module "security" {
  source = "./modules/security"

  environment = var.environment
  vpc_id      = module.networking.vpc_id
  vpc_cidr    = var.vpc_cidr
}







# ECS Base 

module "ecs_base" {
  source = "./modules/ecs"

  environment               = var.environment
  aws_region                = var.aws_region
  vpc_id                    = module.networking.vpc_id
  public_subnet_ids         = module.networking.public_subnet_ids
  alb_security_group_id     = module.security.alb_security_group_id
  certificate_arn           = var.certificate_arn
  enable_container_insights = true
}





# Logging

module "logging" {
  source = "./modules/logging"

  environment        = var.environment
  log_retention_days = 30
}






# Logging

module "logging" {
  source = "./modules/logging"

  environment        = var.environment
  log_retention_days = 30
}

# ECR Repository
module "ecr" {
  source = "./modules/ecr"

  repository_name = "payment-gateway-${var.environment}"
  environment     = var.environment
}
