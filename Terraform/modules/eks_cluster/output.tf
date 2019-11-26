output "eks_cluster_name" {
  value = aws_eks_cluster.master_eks_node.name
}

output "eks_cluster_arn" {
  value = aws_eks_cluster.master_eks_node.arn
}
