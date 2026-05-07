output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}




output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.networking.private_subnet_ids
}




output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.networking.public_subnet_ids
}



output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = module.ecs_base.cluster_id
}




output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_base.cluster_name
}




output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.ecs_base.alb_dns_name
}




output "application_log_group_name" {
  description = "Name of the shared application log group"
  value       = module.logging.application_log_group_name
}




output "application_log_group_name" {
  description = "Name of the shared application log group"
  value       = module.logging.application_log_group_name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}
