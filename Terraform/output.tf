locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.worker.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: ${aws_iam_role.eks_access_role.arn}
      username: ${aws_iam_role.eks_access_role.name}
      groups:
        - system:masters
CONFIGMAPAWSAUTH
}

output "config_map_aws_auth" {
  value = local.config_map_aws_auth
}

output "CLUSTER_NAME" {
  value = module.eks_cluster.eks_cluster_name
}

output "CLUSTER_AUTH_ROLE_ARN" {
  value = aws_iam_role.eks_access_role.arn
}
