resource "aws_autoscaling_group" "worker-asg" {
  desired_capacity     = var.desired_capacity
  launch_configuration = aws_launch_configuration.worker-launch-conf.id
  max_size             = var.max_size
  min_size             = var.min_size
  name                 = var.worker-asg-name
  vpc_zone_identifier  = var.sym-search-subnet-ids

  tag {
    key                 = "Name"
    value               = var.worker-asg-name
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = true
    propagate_at_launch = true
  }
}