data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_role" {
  name               = local.task_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_role" "task_execution_role" {
  name               = local.task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "amazon_task_execution_policy" {
  role = aws_iam_role.task_execution_role.name
  policy_arn = local.amazon_task_excution_role_policy
}

resource "aws_iam_role_policy_attachment" "amazon_s3_full_access_policy" {
  role = aws_iam_role.task_execution_role.name
  policy_arn = local.amazon_s3_full_access_policy
}

data "aws_iam_policy_document" "ssm" {
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ssm_policy" {
  name = "${var.service_name}-ssm-policy"
  path = "/"
  policy = data.aws_iam_policy_document.ssm.json
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.ssm_policy.arn
}


