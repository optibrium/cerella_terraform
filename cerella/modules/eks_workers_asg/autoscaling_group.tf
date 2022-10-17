resource "aws_autoscaling_group" "workers" {
  max_size            = var.max
  min_size            = var.min
  name                = "${var.cluster_name}-workers"
  vpc_zone_identifier = var.eks_subnet_ids

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingCapacity",
    "GroupPendingInstances",
    "GroupStandbyCapacity",
    "GroupStandbyInstances",
    "GroupTerminatingCapacity",
    "GroupTerminatingInstances",
    "GroupTotalCapacity",
    "GroupTotalInstances",
  ]

  max_instance_lifetime = var.max_lifetime * 24 * 3600 # Convert days to seconds
  termination_policies  = ["OldestInstance", "OldestLaunchConfiguration", "Default"]

  launch_template {
    id = aws_launch_template.workers.id
    version            = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "SSM"
    value               = "linux"
    propagate_at_launch = true
  }


  tag {
    key                 = "kubernetescluster"
    value               = var.cluster_name
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [target_group_arns]
  }
}
