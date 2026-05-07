variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}



variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-1"
}




# Networking
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}




variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}



# ALB / TLS 
variable "certificate_arn" {
  description = "ACM certificate ARN for the HTTPS listener"
  type        = string
}