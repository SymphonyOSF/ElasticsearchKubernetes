resource "aws_eks_node_group" "node_group" {
  cluster_name    = var.cluster-name
  node_group_name = var.worker-asg-name
  node_role_arn   = var.node_role_iam_arn
  subnet_ids      = var.sym-search-subnet-ids
  disk_size       = 10
  instance_types  = [var.instance_type]

  remote_access {
    ec2_ssh_key               = var.ssh_keyname
    // IMPORTANT: If source_security_group_ids is left empty, ssh access will be open to 0.0.0.0/0.
    source_security_group_ids = [var.ssh_sg_id]
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
    Environment                                 = var.environment-tag
  }
}