resource "aws_ecs_cluster" "ecs" {
  name = "${var.name}"

  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider[0].name]
}