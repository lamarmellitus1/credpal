variable "environment" {
  type = string
}

variable "service_name" {
  description = "Name of the ECS service (e.g., agency-banking-api)"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "cluster_id" {
  description = "ECS Cluster ID"
  type        = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "ecs_tasks_security_group_id" {
  type = string
}

variable "task_cpu" {
  type    = number
  default = 256
}

variable "task_memory" {
  type    = number
  default = 512
}

variable "container_image" {
  type    = string
  default = "nginx:latest"
}

variable "container_port" {
  type    = number
  default = 80
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "min_tasks" {
  type    = number
  default = 1
}

variable "max_tasks" {
  type    = number
  default = 3
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "task_execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "alb_listener_arn" {
  description = "ALB Listener ARN"
  type        = string
}

variable "host_header" {
  description = "Host header for ALB routing (e.g., agency-banking.paymi.com.ng)"
  type        = string
}

variable "priority" {
  description = "Priority for ALB listener rule"
  type        = number
}

variable "cpu_target_value" {
  type    = number
  default = 70
}

variable "memory_target_value" {
  type    = number
  default = 80
}

variable "request_count_target_value" {
  type    = number
  default = 1000
}

variable "alb_arn_suffix" {
  type = string
}
