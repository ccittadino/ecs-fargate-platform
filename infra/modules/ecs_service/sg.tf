# Security group for ECS service
# allowing ingress from ALB and egress to the internet

resource "aws_security_group" "ecs_service_sg" {
  name        = "${var.name_prefix}-ecs-service-sg"
  description = "Security group for ECS service"
  vpc_id      = var.vpc_id

  tags = local.tags
}

resource "aws_vpc_security_group_ingress_rule" "allow_alb_ingress" {
  for_each                     = var.allowed_ingress_sg_ids
  security_group_id            = aws_security_group.ecs_service_sg.id
  ip_protocol                  = "tcp"
  from_port                    = var.container_port
  to_port                      = var.container_port
  referenced_security_group_id = each.value
}

resource "aws_vpc_security_group_egress_rule" "allow_egress" {
  security_group_id = aws_security_group.ecs_service_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
