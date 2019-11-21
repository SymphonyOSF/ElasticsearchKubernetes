locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.worker-iam.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
  mapUsers: |
    - userarn: arn:aws:iam::189141687483:user/uppinder.chugh@symphony.com
      username: uppinder.chugh@symphony.com
      groups:
        - system:masters
    - userarn: arn:aws:iam::189141687483:user/arn:aws:iam::189141687483:user/serkan
      username: serkan
      groups:
        - system:masters
    - userarn: arn:aws:iam::189141687483:user/long.zuo
      username: long.zuo
      groups:
        - system:masters
    - userarn: arn:aws:iam::189141687483:user/ptzafos
      username: ptzafos
      groups:
        - system:masters
CONFIGMAPAWSAUTH
}

output "config_map_aws_auth" {
  value = local.config_map_aws_auth
}