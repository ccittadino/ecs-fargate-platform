# Bootstraps remote Terraform state: S3 bucket + DynamoDB lock table

# Generate a random suffix so the S3 bucket name is globally unique
resource "random_id" "name" {
  byte_length = 4
}

# Create an S3 bucket for Terraform state storage
resource "aws_s3_bucket" "tf_state" {
  bucket = "${var.bucket_name}-${random_id.name.hex}"

  tags = {
    Project   = var.project_name
    Purpose   = "Terraform state storage"
    ManagedBy = "Terraform"
  }
}

# Enable bucket versioning
resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Block public bucket access
resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable server-side bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# Create a DynamoDB table for Terraform state locking
resource "aws_dynamodb_table" "tf_locks" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Project   = var.project_name
    Purpose   = "Terraform state locking"
    ManagedBy = "Terraform"
  }
}

