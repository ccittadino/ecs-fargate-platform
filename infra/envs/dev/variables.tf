# Variables for the dev environment

variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
}

variable "project_name" {
  type        = string
  description = "Name of the project for tagging resources"
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, staging, prod)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "container_image" {
  type        = string
  description = "Container image to deploy in the ECS service"
  validation {
    condition     = length(trimspace(var.container_image)) > 0
    error_message = "container_image must be a non empty image URI."
  }
}

variable "container_port" {
  type        = number
  description = "Port on which the container listens"
  default     = 80
}

variable "desired_count" {
  type        = number
  description = "Number of desired tasks for the ECS service"
  default     = 2
}

variable "cpu" {
  type        = number
  description = "CPU units for the ECS task"
  default     = 256
}

variable "memory" {
  type        = number
  description = "Memory in MiB for the ECS task"
  default     = 512
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain logs in CloudWatch"
  default     = 7
}

variable "alarm_email" {
  type        = string
  description = "Email address to receive CloudWatch alarm notifications"
  default     = ""
}
