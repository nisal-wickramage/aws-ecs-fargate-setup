locals {
  project_code = "nisal"
  vpc_name     = "${local.project_code}-vpc"

  vpc_cidr = "172.17.0.0/25"
  subnets = {
    "alb_a" = {
      cidr = "172.17.0.0/28"
      az   = "ap-southeast-1a"
    },
    "alb_b" = {
      cidr = "172.17.0.16/28"
      az   = "ap-southeast-1b"
    },
    "ecs_a" = {
      cidr = "172.17.0.32/28"
      az   = "ap-southeast-1a"
    },
    "ecs_b" = {
      cidr = "172.17.0.48/28"
      az   = "ap-southeast-1b"
    },
    "db_a" = {
      cidr = "172.17.0.64/28"
      az   = "ap-southeast-1a"
    },
    "db_b" = {
      cidr = "172.17.0.80/28"
      az   = "ap-southeast-1b"
    },
    "vpce_a" = {
      cidr = "172.17.0.96/28"
      az   = "ap-southeast-1a"
    },
    "vpce_b" = {
      cidr = "172.17.0.112/28"
      az   = "ap-southeast-1b"
    }
  }

  vpce_subnet_ids = toset([for each in aws_subnet.subnets : each.id if length(regexall("vpce", each.tags_all["Name"])) > 0])

  interface_vpc_endpoints = {
    "ecr_dkr" = {
      service_name = "com.amazonaws.ap-southeast-1.ecr.dkr"
      subnet_ids   = local.vpce_subnet_ids
    },
    "ecr_api" = {
      service_name = "com.amazonaws.ap-southeast-1.ecr.api"
      subnet_ids   = local.vpce_subnet_ids
    },
    "logs" = {
      service_name = "com.amazonaws.ap-southeast-1.logs"
      subnet_ids   = local.vpce_subnet_ids
    },
    "ssm" = {
      service_name = "com.amazonaws.ap-southeast-1.ssmmessages"
      subnet_ids   = local.vpce_subnet_ids
    },
  }

  ecs_cluster_name         = "${local.project_code}-ecs-cluster"
  launch_type              = "FARGATE"
  task_execution_role_name = "${local.project_code}-ecs-task-execution"
  ecs_subnet_ids           = toset([for each in aws_subnet.subnets : each.id if length(regexall("ecs", each.tags_all["Name"])) > 0]) 
  task_log_group_name      = "${local.project_code}-task-log-group"
  log_retention_in_days    = 7

  ecs_services = {
    "nginx" = {
      subnet_ids = local.ecs_subnet_ids
    },
    "postgres" = {
      subnet_ids = local.ecs_subnet_ids
      environment_variables = {
        environment = [
          {
            "name"  = "POSTGRES_PASSWORD"
            "value" = "default"
          }
      ] }
    }
  }

  db_subnet_ids           = toset([for each in aws_subnet.subnets : each.id if length(regexall("db", each.tags_all["Name"])) > 0]) 
}
