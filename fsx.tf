resource "aws_fsx_windows_file_system" "ecs" {
  active_directory_id = aws_directory_service_directory.ecs.id
  kms_key_id          = aws_kms_key.ecs.arn
  storage_capacity    = 300
  subnet_ids          = [aws_subnet.ecs.id]
  throughput_capacity = 1024


  tags = {
    Name   = "ecs-${var.name}"
    Backup = var.backup
  }

}



resource "aws_security_group" "fsx" {
  count       = var.create_fsx ? 1 : 0
  name        = "ecs-${var.name}-efs"
  description = "for EFS to talk to ECS cluster"
  vpc_id      = var.vpc_id

  tags = {
    Name = "ecs-fsx-${var.name}"
  }
}

resource "aws_security_group_rule" "fsx_from_ecs_to_efs" {
  count                    = var.create_fsx ? 1 : 0
  description              = "ECS to FSX"
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.fsx[0].id
  source_security_group_id = aws_security_group.ecs_nodes.id
}