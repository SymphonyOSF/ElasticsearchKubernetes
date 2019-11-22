//This file has to exist in the base directory as it has to be the same for all nodes.
resource "aws_iam_role" "worker-iam" {
  name = "node_iam"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "worker_auto_scale_policy" {
  name        = "worker_auto_scale_policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "worker_dns_change_policy" {
  name        = "worker_dns_change_policy"
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
  name = "s3_policy"
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

resource "aws_iam_role_policy_attachment" "worker-node-AmazonEKSWorkerS3Policy" {
  policy_arn = aws_iam_policy.s3_policy.arn
  role       = aws_iam_role.worker-iam.name
}

resource "aws_iam_role_policy_attachment" "worker-node-AmazonEKSWorkerDnsPolicy" {
  policy_arn = aws_iam_policy.worker_dns_change_policy.arn
  role       = aws_iam_role.worker-iam.name
}

resource "aws_iam_role_policy_attachment" "worker-node-AmazonEKSWorkerAutoScalePolicy" {
  policy_arn = aws_iam_policy.worker_auto_scale_policy.arn
  role       = aws_iam_role.worker-iam.name
}

resource "aws_iam_role_policy_attachment" "worker-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker-iam.name
}

resource "aws_iam_role_policy_attachment" "worker-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker-iam.name
}

resource "aws_iam_role_policy_attachment" "worker-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker-iam.name
}

resource "aws_iam_instance_profile" "worker-instance-profile" {
  name = "worker-instance-profile"
  role = aws_iam_role.worker-iam.name
}