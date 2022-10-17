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
    launch_template_specification {
      launch_template_id = aws_launch_template.workers.id
      version            = "$Latest"
    }
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

  dynamic "tag" {
    for_each = var.apply_taints ? var.node_taints : {}

    content {
      key                 = "k8s.io/cluster-autoscaler/node-template/taint/${tag.key}"
      value               = tag.value
      propagate_at_launch = true
    }
  }

  dynamic "tag" {
    for_each = var.cluster_autoscaler ? var.node_labels : {}

    content {
      key                 = "k8s.io/cluster-autoscaler/node-template/label/${tag.key}"
      value               = tag.value
      propagate_at_launch = true
    }
  }

  dynamic "tag" {
    for_each = var.tag_group != null ? [1] : []

    content {
      key                 = "Group"
      value               = var.tag_group
      propagate_at_launch = true
    }
  }

  lifecycle {
    ignore_changes = [target_group_arns]
  }
}

# resource "aws_autoscaling_schedule" "workers_offhours" {
#   count                  = var.off_hours_recurrence != "" ? 1 : 0
#   scheduled_action_name  = "off-hours"
#   min_size               = 1
#   max_size               = 1
#   desired_capacity       = 1
#   recurrence             = var.off_hours_recurrence
#   autoscaling_group_name = aws_autoscaling_group.workers.name
# }

# resource "aws_autoscaling_schedule" "workers_workhours" {
#   count                  = var.work_hours_recurrence != "" ? 1 : 0
#   scheduled_action_name  = "work-hours"
#   max_size               = var.max
#   min_size               = var.min
#   desired_capacity       = var.min
#   recurrence             = var.work_hours_recurrence
#   autoscaling_group_name = aws_autoscaling_group.workers.name
# }
