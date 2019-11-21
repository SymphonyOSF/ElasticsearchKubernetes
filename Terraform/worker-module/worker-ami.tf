//data "aws_ami" "eks-worker" {
//  filter {
//    name   = "name"
//    values = ["amazon-eks-node-${var.master-eks-node-version}-v*"]
//  }
//
//  most_recent = true
//  owners      = ["602401143452"] # Amazon EKS AMI Account ID
//
//  tags = {
//    Name                                        = "elasticEksCluster"
//    "Owner:team"                                = "search"
//    Org                                         = "engineering"
//    Customer                                    = "symphony"
//    CreatedBy                                   = "terraform"
//    Environment                                 = var.environment-tag
//  }
//}