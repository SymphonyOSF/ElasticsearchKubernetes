resource "aws_eks_cluster" "master_eks_node" {
  name            = var.cluster_name
  role_arn        = aws_iam_role.master.arn
  enabled_cluster_log_types = ["api", "audit", "authenticator", "scheduler"]

  vpc_config {
    security_group_ids = [aws_security_group.master.id]
    subnet_ids         = var.subnet_id_list
  }

  depends_on = [
    aws_iam_role_policy_attachment.sym_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.sym_cluster_AmazonEKSServicePolicy
  ]
}
