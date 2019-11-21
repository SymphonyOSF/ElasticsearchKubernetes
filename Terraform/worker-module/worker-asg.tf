//resource "aws_autoscaling_group" "worker-asg" {
//  desired_capacity     = var.desired_capacity
//  launch_configuration = aws_launch_configuration.worker-launch-conf.id
//  max_size             = var.max_size
//  min_size             = var.min_size
//  name                 = var.worker-asg-name
//  vpc_zone_identifier  = var.sym-search-subnet-ids
//
//  tags = [
//    {
//      key                 = "k8s.io/cluster-autoscaler/${var.cluster-name}"
//      value               = "owned"
//      propagate_at_launch = true
//    },
//    {
//      key                 = "k8s.io/cluster-autoscaler/enabled"
//      value               = true
//      propagate_at_launch = true
//    },
//    {
//      key                 = "kubernetes.io/cluster/${var.cluster-name}"
//      value               = "owned"
//      propagate_at_launch = true
//    },
//    {
//      key                 = "Name"
//      value               = "elasticEksCluster"
//      propagate_at_launch = true
//    },
//    {
//      key                 = "Owner:team"
//      value               = "search"
//      propagate_at_launch = true
//    },
//    {
//      key                 = "Org"
//      value               = "engineering"
//      propagate_at_launch = true
//    },
//    {
//      key                 = "Customer"
//      value               = "symphony"
//      propagate_at_launch = true
//    },
//    {
//      key                 = "CreatedBy"
//      value               = "terraform"
//      propagate_at_launch = true
//    },
//    {
//      key                 = "Environment"
//      value               = var.environment-tag
//      propagate_at_launch = true
//    }
//  ]
//}