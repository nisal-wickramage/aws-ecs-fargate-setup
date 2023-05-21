resource "aws_cloudwatch_log_group" "this" {
  name              = var.service_name
  retention_in_days = var.log_retention_in_days
  tags = {
    "Name" = var.service_name
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.service_name
  requires_compatibilities = [local.launch_type]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
  container_definitions = jsonencode([merge(
    {
      name      = var.service_name
      image     = "${var.ecr_uri}:latest"
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
          awslogs-group         = aws_cloudwatch_log_group.this.id
          awslogs-region        = local.region
          awslogs-stream-prefix = "ecs"
        }
      }
    },
    var.environment_variables,
    var.secrets
  )])
}

resource "aws_ecs_service" "this" {
  name                   = var.service_name
  cluster                = var.ecs_cluster_id
  task_definition        = aws_ecs_task_definition.this.arn
  desired_count          = 1
  launch_type            = local.launch_type
  enable_execute_command = true

  network_configuration {
    subnets          = var.service_subnet_ids
    assign_public_ip = false
  }

  tags = {
    "Name" = var.service_name
  }
  propagate_tags = "SERVICE"
}




