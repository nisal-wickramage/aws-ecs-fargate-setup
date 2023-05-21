resource "aws_vpc_endpoint" "interface_endpoints" {
  for_each            = local.interface_vpc_endpoints
  vpc_id              = aws_vpc.this.id
  private_dns_enabled = true
  service_name        = each.value.service_name
  subnet_ids          = each.value.subnet_ids
  vpc_endpoint_type = "Interface"

  tags = {
    "Name" = each.key
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id = aws_vpc.this.id
  service_name        = "com.amazonaws.ap-southeast-1.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    "Name" = "s3"
  }
}

resource "aws_vpc_endpoint_route_table_association" "s3-route" {
  route_table_id  = aws_default_route_table.this.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}
