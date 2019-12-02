resource "aws_eks_node_group" "node_group" {
  cluster_name    = var.cluster_name
  node_group_name = var.worker_asg_name
  node_role_arn   = var.node_role_iam_arn
  subnet_ids      = var.sym_search_subnet_ids
  disk_size       = 10
  instance_types  = [var.instance_type]


  dynamic "remote_access" {
    // Little hack, if there are security_groups defined on the list, will create this block once.
    // If there is no security_groups defined, will not create this block at all.
    for_each = var.enable_ssh_access == true && length(var.ssh_sg_id_list) >= 1  ? [1] : []
    content {
      ec2_ssh_key               = var.ssh_keyname
      source_security_group_ids = var.ssh_sg_id_list
    }
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
