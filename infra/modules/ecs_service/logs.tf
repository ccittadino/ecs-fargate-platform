# CloudWatch Log Group for ECS Task Logs

resource "aws_cloudwatch_log_group" "ecs_task_log_group" {
  name              = "/ecs/${var.name_prefix}-task-logs"
  retention_in_days = var.log_retention_days

  tags = local.tags
}
