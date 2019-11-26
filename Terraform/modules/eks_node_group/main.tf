resource "aws_eks_node_group" "node_group" {
  cluster_name    = var.cluster_name
  node_group_name = var.worker_asg_name
  node_role_arn   = var.node_role_iam_arn
  subnet_ids      = var.sym_search_subnet_ids
  disk_size       = 10
  instance_types  = [var.instance_type]

  remote_access {
    ec2_ssh_key               = var.ssh_keyname
    // IMPORTANT: If source_security_group_ids is left empty, ssh access will be open to 0.0.0.0/0.
    source_security_group_ids = [aws_security_group.worker_ssg_sg.id]
  }

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_size
    min_size     = var.min_size
  }

  tags = {
    Name                                        = "elasticEksCluster"
    "Owner:team"                                = "search"
    Org                                         = "engineering"
    Customer                                    = "symphony"
    CreatedBy                                   = "terraform"
    Environment                                 = var.environment_tag
  }
}
