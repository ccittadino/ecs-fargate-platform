# Local values for the network module

locals {
  tags = merge(
    var.tags,
    {
      Module = "network"
    }
  )
}
