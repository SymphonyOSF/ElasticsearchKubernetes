//This file has to exist in the base directory as it has to be the same for all nodes.
resource "aws_iam_role" "worker" {
  name = "${var.eks_cluster_name}_node_iam"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "worker_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "worker_node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "worker_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_policy" "worker_auto_scale_policy" {
  name        = "${var.eks_cluster_name}_worker_auto_scale_policy"
  policy = jsonencode({
    Statement = [{
      Action = [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions"
      ]
      Resource = "*"
      Effect = "Allow"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy" "worker_dns_change_policy" {
  name        = "${var.eks_cluster_name}_worker_dns_change_policy"
  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Action": [
       "route53:ChangeResourceRecordSets"
     ],
     "Resource": [
       "arn:aws:route53:::hostedzone/*"
     ]
   },
   {
     "Effect": "Allow",
     "Action": [
       "route53:ListHostedZones",
       "route53:ListResourceRecordSets"
     ],
     "Resource": [
       "*"
     ]
   }
 ]
}
EOF
}

resource "aws_iam_policy" "s3_policy" {
  name = "${var.eks_cluster_name}_s3_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "worker_node_AmazonEKSWorkerS3Policy" {
  policy_arn = aws_iam_policy.s3_policy.arn
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "worker_node_AmazonEKSWorkerDnsPolicy" {
  policy_arn = aws_iam_policy.worker_dns_change_policy.arn
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "worker_node_AmazonEKSWorkerAutoScalePolicy" {
  policy_arn = aws_iam_policy.worker_auto_scale_policy.arn
  role       = aws_iam_role.worker.name
}

resource "aws_iam_instance_profile" "worker_instance_profile" {
  name = "${var.eks_cluster_name}_worker_instance_profile"
  role = aws_iam_role.worker.name
}
