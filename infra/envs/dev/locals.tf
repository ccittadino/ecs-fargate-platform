# Local values for the dev environment

locals {
  env = lower(var.environment)

  name_prefix = lower("${var.project_name}-${local.env}")

  region = lower(var.aws_region)

  tags = {
    Project     = var.project_name
    Environment = local.env
    ManagedBy   = "Terraform"
  }
}
