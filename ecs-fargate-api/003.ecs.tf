resource "aws_ecr_repository" "repositories" {
  for_each             = local.ecs_services
  name                 = each.key
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    "Name" = each.key
  }
}

resource "aws_ecs_cluster" "this" {
  name = local.ecs_cluster_name

  tags = {
    "Name" = local.ecs_cluster_name
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = [local.launch_type]
}

resource "aws_ecs_task_definition" "this" {
  family                   = "service"
  requires_compatibilities = [local.launch_type]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.task_execution_role.arn
  container_definitions = jsonencode([{
    name      = "nginx"
    image     = "${aws_ecr_repository.repositories["nginx"].repository_url}:latest"
    cpu       = 1024
    memory    = 2048
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.task.id
        awslogs-region        = local.region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "this" {
  name                   = "nginx"
  cluster                = aws_ecs_cluster.this.id
  task_definition        = aws_ecs_task_definition.this.arn
  desired_count          = 1
  launch_type            = local.launch_type
  enable_execute_command = true

  network_configuration {
    subnets          = local.ecs_subnet_ids
    assign_public_ip = false
  }

  tags = {
    "Name" = "nginx"
  }
  propagate_tags = "SERVICE"
}


