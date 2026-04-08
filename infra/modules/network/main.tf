# VPC, subnets, internet gateway, and NAT gateways for platform networking

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.tags,
    {
      Name = "${var.name_prefix}-vpc"
    }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.tags,
    {
      Name = "${var.name_prefix}-igw"
    }
  )
}

resource "aws_subnet" "public" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.tags,
    {
      Name = "${var.name_prefix}-public-subnet-${data.aws_availability_zones.available.names[count.index]}"
    }
  )
}

resource "aws_subnet" "private" {
  count             = var.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + var.az_count)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    local.tags,
    {
      Name = "${var.name_prefix}-private-subnet-${data.aws_availability_zones.available.names[count.index]}"
    }
  )
}

resource "aws_eip" "nat" {
  count = var.az_count

  domain = "vpc"

  tags = merge(
    local.tags,
    {
      Name = "${var.name_prefix}-nat-eip-${data.aws_availability_zones.available.names[count.index]}"
    }
  )
}

resource "aws_nat_gateway" "main" {
  count         = var.az_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  depends_on = [aws_internet_gateway.main]

  tags = merge(
    local.tags,
    {
      Name = "${var.name_prefix}-nat-gateway-${data.aws_availability_zones.available.names[count.index]}"
    }
  )
}
