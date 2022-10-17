resource "aws_launch_template" "workers" {
  name_prefix   = "${var.cluster_name}-workers"
  image_id      = data.aws_ami.workers_ami.id
  instance_type = var.instance_type
  user_data     = base64encode(local.workers_userdata)

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = var.disk_size
      volume_type = var.disk_type
      iops        = var.disk_iops
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.worker_nodes.name
  }

  vpc_security_group_ids = var.security_group_ids

  monitoring {
    enabled = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
  }

  tags = {
    Name = "${var.cluster_name}-workers"
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "${var.cluster_name}-workers"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
