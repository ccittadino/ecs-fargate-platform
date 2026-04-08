# Local values for the ecs_service module

locals {
  container_name = "${var.name_prefix}-container"

  tags = merge(
    var.tags,
    {
      Module = "ecs_service"
    }
  )
}
