data "template_file" "userdata" {
  template = file("${path.module}/userdata.tpl")
  
  vars = {
    tf_cluster_name = var.name
    tf_fsx_id       = aws_fsx_windows_file_system.ecs[0].id
    userdata_extra  = var.userdata
  }
}


resource "aws_launch_template" "ecs" {
  name_prefix   = "ecs-${var.name}-"
  image_id      = data.aws_ami.amzn.image_id
  instance_type = length(var.instance_types) == 0 ? "t2.micro" : var.instance_types[0]
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = var.instance_volume_size_root
    }
  }
  
  vpc_security_group_ids = concat(list(aws_security_group.ecs_nodes.id), var.security_group_ids)

  user_data = base64encode(data.template_file.userdata.rendered)

  lifecycle {
    create_before_destroy = true
  }
}

resource "tls_private_key" "algorithm" {
  count     = var.ec2_key_enabled ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  count      = var.ec2_key_enabled ? 1 : 0
  key_name   = "${var.name}-key"
  public_key = tls_private_key.algorithm[0].public_key_openssh
}