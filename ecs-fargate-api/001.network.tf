resource "aws_vpc" "this" {
  cidr_block           = local.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = local.vpc_name
  }
}

resource "aws_subnet" "subnets" {
  for_each          = local.subnets
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  vpc_id            = aws_vpc.this.id
  tags  = {
    "Name" = each.key,
  }
}

resource "aws_default_route_table" "this" {
  default_route_table_id = aws_vpc.this.default_route_table_id
}
