resource "aws_iam_role" "ecs_task" {
  count = var.create_iam_roles ? 1 : 0
  name = "ecs-task-${var.name}-${data.aws_region.current.name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  count = var.create_iam_roles ? 1 : 0
  role       = aws_iam_role.ecs_task[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ssm_policy" {
  count = var.create_iam_roles ? 1 : 0
  name = "ecs-ssm-policy"
  role = aws_iam_role.ecs_task[0].name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters"
      ],
      "Resource": [
        "arn:aws:ssm:*:*:parameter/*"
      ]
    }
  ]
}
EOF
}
