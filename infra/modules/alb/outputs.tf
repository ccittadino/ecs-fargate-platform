# Outputs for the ALB module

output "sg_id" {
  description = "The security group ID for the ALB"
  value       = aws_security_group.alb_sg.id
}

output "arn" {
  description = "The ARN of the ALB"
  value       = aws_lb.this.arn
}

output "dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.this.dns_name
}

output "target_group_arn" {
  description = "The ARN of the ALB target group"
  value       = aws_lb_target_group.this.arn
}

output "arn_suffix" {
  description = "The ARN suffix for the ALB, useful for IAM policies"
  value       = aws_lb.this.arn_suffix
}

output "target_group_arn_suffix" {
  description = "The ARN suffix for the ALB target group, useful for IAM policies"
  value       = aws_lb_target_group.this.arn_suffix
}
