//EKS Master role
resource "aws_iam_role" "master" {

  name = "${var.cluster_name}_master_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    Name            = "elasticEksCluster"
    "Owner:team"    = "search"
    Org             = "engineering"
    Customer        = "symphony"
    CreatedBy       = "terraform"
    Environment     = var.environment_tag
  }
}

resource "aws_iam_role_policy_attachment" "sym_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.master.name
}

resource "aws_iam_role_policy_attachment" "sym_cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.master.name
}
