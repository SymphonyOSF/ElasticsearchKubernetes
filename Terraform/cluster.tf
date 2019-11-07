terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
}

module "data-node-workers" {
  source                                      = "./worker-module"
  worker-asg-name                             = "data-node-workers"
  master-eks-node-version                     = aws_eks_cluster.master-eks-node.version
  sym-search-subnet-ids                       = [aws_subnet.sym-search-subnet.0.id]
  cluster-name                                = var.cluster-name
  master-eks-node-endpoint                    = aws_eks_cluster.master-eks-node.endpoint
  master-eks-node-certificate-authority-data  = aws_eks_cluster.master-eks-node.certificate_authority.0.data
  sym-search-vpc-id                           = aws_vpc.sym-search-vpc.id
  aws-security-group-master-sg-id             = aws_security_group.master-sg.id
  desired_capacity                            = 2
  instance_type                               = "c5.9xlarge"
  min_size                                    = 2
  max_size                                    = 10
  other_group_sg_id                           = module.master-node-workers.security_group_id
  aws_iam_instance_profile_name               = aws_iam_instance_profile.worker-instance-profile.name
  ssh_keyname                                 = aws_key_pair.eks-nodes-key.key_name
}

module "master-node-workers" {
  source                                      = "./worker-module"
  worker-asg-name                             = "master-node-workers"
  master-eks-node-version                     = aws_eks_cluster.master-eks-node.version
  sym-search-subnet-ids                       = aws_subnet.sym-search-subnet.*.id
  cluster-name                                = var.cluster-name
  master-eks-node-endpoint                    = aws_eks_cluster.master-eks-node.endpoint
  master-eks-node-certificate-authority-data  = aws_eks_cluster.master-eks-node.certificate_authority.0.data
  sym-search-vpc-id                           = aws_vpc.sym-search-vpc.id
  aws-security-group-master-sg-id             = aws_security_group.master-sg.id
  desired_capacity                            = 1
  instance_type                               = "c5.4xlarge"
  min_size                                    = 1
  max_size                                    = 3
  other_group_sg_id                           = module.data-node-workers.security_group_id
  aws_iam_instance_profile_name               = aws_iam_instance_profile.worker-instance-profile.name
  ssh_keyname                                 = aws_key_pair.eks-nodes-key.key_name
}
