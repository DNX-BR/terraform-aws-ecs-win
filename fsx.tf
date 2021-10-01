resource "aws_fsx_windows_file_system" "ecs" {
  count       = var.create_fsx ? 1 : 0
  kms_key_id     = var.kms_key_arn != "" ? var.kms_key_arn : null
  storage_capacity    = 300
  subnet_ids      = list(element(var.secure_subnet_ids, count.index))
  throughput_capacity = 1024


  self_managed_active_directory {
    dns_ips     = var.fsx_dns_ips
    domain_name = var.fsx_domain_name
    password    = var.fsx_password
    username    = var.fsx_username
  }


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