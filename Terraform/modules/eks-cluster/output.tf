output "eks_cluster_name" {
  value = aws_eks_cluster.master-eks-node.name
}