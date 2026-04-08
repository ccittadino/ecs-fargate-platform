# Remote backend configuration
#
# BEFORE running `terraform init`:
# 1. Copy `envs/dev/backend.tfbackend.example` to `envs/dev/backend.tfbackend`
# 2. Update the values (bucket, region, dynamodb_table)
# 3. Run:
#      terraform init -backend-config="backend.tfbackend"
#
# This file only defines the backend type
# The actual backend settings are supplied via the .tfbackend file

terraform {
  backend "s3" {
    key     = "terraform.tfstate"
    encrypt = true
  }
}
