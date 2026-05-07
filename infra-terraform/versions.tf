terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }



}



provider "aws" {
  region = "us-west-1"

  default_tags {
    tags = {
      Project     = "damolaktech"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Company     = "damolaktech"
    }
  }
}
