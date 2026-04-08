# Variables for the bootstrap module

variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Name of the project for tagging resources"
}

variable "bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name for Terraform remote state"
}

variable "dynamodb_table_name" {
  type        = string
  description = "Name of the DynamoDB table to create for state locking"
}
