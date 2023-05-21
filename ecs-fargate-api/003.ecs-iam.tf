data "aws_iam_policy_document" "ecs_tasks_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_execution_role" {
  name               = local.task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role.json
}

resource "aws_iam_role_policy_attachment" "amazon_task_execution_policy" {
  role = aws_iam_role.task_execution_role.name
  policy_arn = local.amazon_task_excution_role_policy
}

resource "aws_iam_role_policy_attachment" "amazon_s3_full_access_policy" {
  role = aws_iam_role.task_execution_role.name
  policy_arn = local.amazon_s3_full_access_policy
}


