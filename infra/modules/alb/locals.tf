# Local values for the alb module

locals {
  tags = merge(
    var.tags,
    {
      Module = "alb"
    }
  )
}
