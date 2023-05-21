variable "service_name" {
    type = string
    description = "Name of the ECS service"
}

variable "log_retention_in_days" {
    type = number
    description = "Number of days to retain cloud watch logs"
}

variable "ecr_uri" {
    type = string
    description = "ECR URI"
}

variable "ecs_cluster_id" {
  type = string
  description = "ECS cluster id"
}

variable "service_subnet_ids" {
  type = list(string)
  description = "List of subnets ids to deploy the service to"
}

variable "environment_variables" {
  type = map
  description = "Environment variables for container definition"
  default = {}
}

variable "secrets" {
  type = map
  description = "Secrets to be injected as environment variables"
  default = {}
}