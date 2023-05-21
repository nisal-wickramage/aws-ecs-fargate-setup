locals {
  task_role_name                   = "${var.service_name}-task-role"
  task_execution_role_name         = "${var.service_name}-task-execution-role"
  amazon_task_excution_role_policy = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  amazon_s3_full_access_policy     = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  launch_type = "FARGATE"
  region = data.aws_region.current.name
}
