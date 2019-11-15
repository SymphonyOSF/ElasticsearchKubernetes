terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
}

resource "aws_security_group" "central-node-sg" {
  name        = "central-node-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.sym-search-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                        = "terraform-eks-central-sg"
  }

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
  desired_capacity                            = var.desired_num_data_nodes
  instance_type                               = var.data_node_instante_type
  min_size                                    = var.min_num_data_nodes
  max_size                                    = var.max_num_data_nodes
  central_sg_id                               = aws_security_group.central-node-sg.id
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
  desired_capacity                            = var.desired_num_master_nodes
  instance_type                               = var.master_node_instante_type
  min_size                                    = var.min_num_master_nodes
  max_size                                    = var.max_num_master_nodes
  central_sg_id                               = aws_security_group.central-node-sg.id
  aws_iam_instance_profile_name               = aws_iam_instance_profile.worker-instance-profile.name
  ssh_keyname                                 = aws_key_pair.eks-nodes-key.key_name
}

# Start service group nodes

module "service-node-workers" {
  source                                      = "./worker-module"
  worker-asg-name                             = "service-node-workers"
  master-eks-node-version                     = aws_eks_cluster.master-eks-node.version
  sym-search-subnet-ids                       = aws_subnet.sym-search-subnet.*.id
  cluster-name                                = var.cluster-name
  master-eks-node-endpoint                    = aws_eks_cluster.master-eks-node.endpoint
  master-eks-node-certificate-authority-data  = aws_eks_cluster.master-eks-node.certificate_authority.0.data
  sym-search-vpc-id                           = aws_vpc.sym-search-vpc.id
  aws-security-group-master-sg-id             = aws_security_group.master-sg.id
  desired_capacity                            = var.desired_num_service_nodes
  instance_type                               = var.service_node_instante_type
  min_size                                    = var.min_num_service_nodes
  max_size                                    = var.max_num_service_nodes
  central_sg_id                               = aws_security_group.central-node-sg.id
  aws_iam_instance_profile_name               = aws_iam_instance_profile.worker-instance-profile.name
  ssh_keyname                                 = aws_key_pair.eks-nodes-key.key_name
}
