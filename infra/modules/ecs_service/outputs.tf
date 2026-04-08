# Outputs for ECS Service module

output "log_group_name" {
  value       = aws_cloudwatch_log_group.ecs_task_log_group.name
  description = "Name of the CloudWatch log group for ECS task logs"
}

output "ecs_task_execution_role_arn" {
  value       = aws_iam_role.ecs_task_execution_role.arn
  description = "ARN of the IAM role for ECS task execution"
}

output "ecs_task_role_arn" {
  value       = aws_iam_role.ecs_task_role.arn
  description = "ARN of the IAM role for ECS tasks"
}
output "sg_id" {
  value       = aws_security_group.ecs_service_sg.id
  description = "ID of the security group for the ECS service"
}
