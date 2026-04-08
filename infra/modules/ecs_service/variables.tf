# Variables for the ECS Service module

variable "region" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "target_group_arn" {
  type = string
}

variable "allowed_ingress_sg_ids" {
  type = map(string)
}

variable "container_image" {
  type = string
}

variable "container_port" {
  type     = number
  nullable = false

  validation {
    condition     = var.container_port >= 1 && var.container_port <= 65535
    error_message = "container_port must be between 1 and 65535."
  }
}

variable "desired_count" {
  type     = number
  nullable = false

  validation {
    condition     = var.desired_count >= 0
    error_message = "desired_count must be >= 0."
  }
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "log_retention_days" {
  type    = number
  default = 7
}

