resource "aws_eks_cluster" "master-eks-node" {
  name            = var.cluster-name
  role_arn        = aws_iam_role.sym-search-iam.arn

  vpc_config {
    security_group_ids = [aws_security_group.master-sg.id]
    subnet_ids         = aws_subnet.sym-search-subnet.*.id
  }

  depends_on = [
    aws_iam_role_policy_attachment.sym-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.sym-cluster-AmazonEKSServicePolicy
  ]
}