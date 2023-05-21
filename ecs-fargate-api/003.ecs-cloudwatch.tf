
resource "aws_cloudwatch_log_group" "task" {
  name              = local.task_log_group_name
  retention_in_days = local.log_retention_in_days
  tags = {
    "Name" = local.task_log_group_name
  }
}
