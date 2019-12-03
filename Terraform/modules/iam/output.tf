output "worker_role_arn" {
  value = aws_iam_role.worker.arn
}

output "access_role_arn" {
  value = aws_iam_role.eks_access_role.arn
}

output "access_role_name" {
  value = aws_iam_role.eks_access_role.name
}
