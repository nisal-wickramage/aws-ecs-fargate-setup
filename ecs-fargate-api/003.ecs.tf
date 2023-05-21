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

module "ecs_service" {
    for_each = local.ecs_services

    source = "./modules/ecs-service"

    service_name = each.key
    log_retention_in_days = 14
    service_subnet_ids = each.value.subnet_ids
    ecr_uri = aws_ecr_repository.repositories[each.key].repository_url
    ecs_cluster_id = aws_ecs_cluster.this.id
    environment_variables = try(each.value.environment_variables, {})
    secrets = try(each.value.secrets, {})
}