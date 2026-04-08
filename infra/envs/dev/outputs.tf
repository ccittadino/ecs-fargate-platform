# Outputs for the dev environment

output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "vpc_cidr_block" {
  value = module.network.vpc_cidr_block
}

output "alb_security_group_id" {
  value = module.alb.sg_id
}

output "alb_arn" {
  value = module.alb.arn
}

output "alb_dns_name" {
  value = module.alb.dns_name
}

output "alb_target_group_arn" {
  value = module.alb.target_group_arn
}

output "ecs_service_security_group_id" {
  value = module.ecs_service.sg_id
}

output "ecs_task_log_group_name" {
  value = module.ecs_service.log_group_name
}

output "ecs_task_execution_role_arn" {
  value = module.ecs_service.ecs_task_execution_role_arn
}

output "ecs_task_role_arn" {
  value = module.ecs_service.ecs_task_role_arn
}


