terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

locals {
  vpc_cidr = "172.17.0.0/25"
}

resource "aws_ecr_repository" "my-personal-web" {
  name                 = "my-personal-web"
  image_tag_mutability = "MUTABLE"
}

resource "aws_vpc" "main" {
  cidr_block           = local.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "alb_a" {
  cidr_block        = "172.17.0.0/28"
  availability_zone = "ap-southeast-1a"
  vpc_id            = aws_vpc.main.id
}

resource "aws_subnet" "alb_b" {
  cidr_block        = "172.17.0.16/28"
  availability_zone = "ap-southeast-1b"
  vpc_id            = aws_vpc.main.id
}

resource "aws_subnet" "ecs_a" {
  cidr_block        = "172.17.0.32/28"
  availability_zone = "ap-southeast-1a"
  vpc_id            = aws_vpc.main.id
}

resource "aws_subnet" "ecs_b" {
  cidr_block        = "172.17.0.48/28"
  availability_zone = "ap-southeast-1b"
  vpc_id            = aws_vpc.main.id
}

resource "aws_subnet" "vpce_a" {
  cidr_block        = "172.17.0.64/28"
  availability_zone = "ap-southeast-1a"
  vpc_id            = aws_vpc.main.id
}

resource "aws_subnet" "vpce_b" {
  cidr_block        = "172.17.0.80/28"
  availability_zone = "ap-southeast-1b"
  vpc_id            = aws_vpc.main.id
}

resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    env = "dev"
  }
}

resource "aws_network_acl_association" "alb_a" {
  network_acl_id = aws_network_acl.main.id
  subnet_id      = aws_subnet.alb_a.id
}

resource "aws_network_acl_association" "alb_b" {
  network_acl_id = aws_network_acl.main.id
  subnet_id      = aws_subnet.alb_b.id
}

resource "aws_network_acl_association" "ecs_a" {
  network_acl_id = aws_network_acl.main.id
  subnet_id      = aws_subnet.ecs_a.id
}

resource "aws_network_acl_association" "ecs_b" {
  network_acl_id = aws_network_acl.main.id
  subnet_id      = aws_subnet.ecs_b.id
}

resource "aws_network_acl_association" "vpce_a" {
  network_acl_id = aws_network_acl.main.id
  subnet_id      = aws_subnet.vpce_a.id
}

resource "aws_network_acl_association" "vpc_b" {
  network_acl_id = aws_network_acl.main.id
  subnet_id      = aws_subnet.vpce_b.id
}

resource "aws_security_group" "my-personal-web" {

  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

#   ingress {
#     description = "Allow all from VPC"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "all"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

  egress {
    description = "Allow all to VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs" {
  name        = "ecs"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Allow all to VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vpce" {
  name        = "vpce"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Allow all to VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ecs_vpce" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "all"
  source_security_group_id = aws_security_group.ecs.id
  security_group_id        = aws_security_group.vpce.id
}

resource "aws_security_group_rule" "alb_ecs" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "all"
  source_security_group_id = aws_security_group.my-personal-web.id
  security_group_id        = aws_security_group.ecs.id
}

resource "aws_security_group_rule" "ecs_alb" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "all"
  source_security_group_id = aws_security_group.ecs.id
  security_group_id        = aws_security_group.my-personal-web.id
}

resource "aws_vpc_endpoint" "ecr-dkr" {
  vpc_id              = aws_vpc.main.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.ap-southeast-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.vpce_a.id, aws_subnet.vpce_b.id]
  security_group_ids  = [aws_security_group.vpce.id]
}

resource "aws_vpc_endpoint" "ecr-api" {
  vpc_id              = aws_vpc.main.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.ap-southeast-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.vpce_a.id, aws_subnet.vpce_b.id]
  security_group_ids  = [aws_security_group.vpce.id]
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.main.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.ap-southeast-1.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.vpce_a.id, aws_subnet.vpce_b.id]
  security_group_ids  = [aws_security_group.vpce.id]
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.ap-southeast-1.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.vpce_a.id, aws_subnet.vpce_b.id]
  security_group_ids  = [aws_security_group.vpce.id]
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-southeast-1.s3"
  vpc_endpoint_type = "Gateway"
}

resource "aws_default_route_table" "dafault" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  tags = {
    env = "dev"
  }
}

resource "aws_vpc_endpoint_route_table_association" "s3-route" {
  route_table_id  = aws_default_route_table.dafault.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_lb" "my-personal-web" {

  name               = "my-personal-web-lb-tf"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my-personal-web.id]
  subnets            = [aws_subnet.alb_a.id, aws_subnet.alb_b.id]
  tags = {
    env = "dev"
  }
}


resource "aws_lb_target_group" "my-personal-web" {

  name        = "tf-my-personal-web-lb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
}

resource "aws_lb_listener" "my-personal-web" {

  load_balancer_arn = aws_lb.my-personal-web.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-personal-web.arn
  }
}


resource "aws_ecs_cluster" "my-personal-web" {
  name = "my-personal-web-api-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "my-personal-web" {

  cluster_name = aws_ecs_cluster.my-personal-web.name

  capacity_providers = ["FARGATE"]
}

data "aws_iam_policy_document" "ecs_tasks_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}


resource "aws_ecs_task_definition" "my-personal-web" {
  family                   = "service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_tasks_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([
    {
      name      = "my-personal-web-api"
      image     = "${aws_ecr_repository.my-personal-web.repository_url}:latest"
      cpu       = 1024
      memory    = 2048
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "my-personal-web" {

  name            = "my-personal-web"
  cluster         = aws_ecs_cluster.my-personal-web.id
  task_definition = aws_ecs_task_definition.my-personal-web.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = [aws_subnet.ecs_a.id, aws_subnet.ecs_b.id]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.my-personal-web.arn
    container_name   = "my-personal-web-api"
    container_port   = 80
  }

  tags = {
    env = "dev"
  }
}
