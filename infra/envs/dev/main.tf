# Main Terraform configuration for the dev environment
# using the network, ALB, and ECS service modules

module "network" {
  source = "../../modules/network"

  vpc_cidr    = var.vpc_cidr
  region      = local.region
  name_prefix = local.name_prefix
  tags        = local.tags
  az_count    = 2
}

module "alb" {
  source = "../../modules/alb"

  region                     = local.region
  name_prefix                = local.name_prefix
  tags                       = local.tags
  vpc_id                     = module.network.vpc_id
  public_subnet_ids          = module.network.public_subnet_ids
  container_port             = var.container_port
  enable_deletion_protection = false
}

module "ecs_service" {
  source = "../../modules/ecs_service"

  region                 = local.region
  name_prefix            = local.name_prefix
  tags                   = local.tags
  vpc_id                 = module.network.vpc_id
  private_subnet_ids     = module.network.private_subnet_ids
  target_group_arn       = module.alb.target_group_arn
  allowed_ingress_sg_ids = { alb = module.alb.sg_id }
  container_image        = var.container_image
  container_port         = var.container_port
  desired_count          = var.desired_count
  cpu                    = var.cpu
  memory                 = var.memory
  log_retention_days     = var.log_retention_days
}

# ALB to ECS security group chaining
resource "aws_vpc_security_group_egress_rule" "alb_to_ecs_egress" {
  from_port                    = var.container_port
  to_port                      = var.container_port
  ip_protocol                  = "tcp"
  security_group_id            = module.alb.sg_id
  referenced_security_group_id = module.ecs_service.sg_id
}
