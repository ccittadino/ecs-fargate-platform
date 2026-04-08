# Outputs for the bootstrap module

output "s3_bucket_name" {
  value       = aws_s3_bucket.tf_state.bucket
  description = "Name of the S3 bucket created for Terraform state storage"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.tf_locks.name
  description = "Name of the DynamoDB table created for Terraform state locking"
}

output "aws_region" {
  value       = var.aws_region
  description = "AWS region where the resources were created"
}
