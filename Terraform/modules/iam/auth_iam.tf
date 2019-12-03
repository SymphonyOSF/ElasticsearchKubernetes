data "aws_caller_identity" "current" {}

resource "aws_iam_group" "eks_cluster_masters" {
  name = "${var.eks_cluster_name}_master_users"
}

resource "aws_iam_role" "eks_access_role" {
  name = "${var.eks_cluster_name}_access_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "${data.aws_caller_identity.current.account_id}"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "assume_role_policy" {
  name        = "${var.eks_cluster_name}_assume_role_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "${aws_iam_role.eks_access_role.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "describe_eks_policy" {
  name        = "${var.eks_cluster_name}_describe_eks_policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "eks:DescribeCluster",
            "Resource": "${var.eks_cluster_arn}"
        }
    ]
}
EOF
}

resource "aws_iam_group_policy_attachment" "assume_role_to_eks_masters_attachment" {
  group       = aws_iam_group.eks_cluster_masters.name
  policy_arn  = aws_iam_policy.describe_eks_policy.arn
}

resource "aws_iam_group_policy_attachment" "describe_eks_to_eks_masters_attachment" {
  group       = aws_iam_group.eks_cluster_masters.name
  policy_arn  = aws_iam_policy.assume_role_policy.arn
}
