output "eks_cluster_name" {
  value = aws_eks_cluster.master-eks-node.name
}

output "eks_cluster_arn" {
  value = aws_eks_cluster.master-eks-node.arn
}
