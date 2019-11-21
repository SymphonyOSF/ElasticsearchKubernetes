terraform {
  required_version = ">= 0.12.0"

  backend "s3" {
    bucket          = "search-dev-terraform-backend"
    encrypt         = true
    key             = "terraform.tfstate"
    region          = "us-east-1"
    dynamodb_table  = "sym-search-dev-terraform-lock"
  }
}

provider "aws" {
  version = ">= 2.38.0"
  region  = var.region
}

module "data-node-workers" {
  source                                      = "./worker-module"
  worker-asg-name                             = "data-node-workers"
  sym-search-subnet-ids                       = [aws_subnet.sym-search-subnet.0.id]
  cluster-name                                = aws_eks_cluster.master-eks-node.name
  desired_capacity                            = var.desired_num_data_nodes
  instance_type                               = var.data_node_instante_type
  min_size                                    = var.min_num_data_nodes
  max_size                                    = var.max_num_data_nodes
  ssh_keyname                                 = aws_key_pair.eks-nodes-key.key_name
  environment-tag                             = var.environment-tag
  node_role_iam_arn                           = aws_iam_role.worker-iam.arn
  ssh_sg_id                                   = aws_security_group.worker_ssg_sg.id
}

module "master-node-workers" {
  source                                      = "./worker-module"
  worker-asg-name                             = "master-node-workers"
  sym-search-subnet-ids                       = aws_subnet.sym-search-subnet.*.id
  cluster-name                                = aws_eks_cluster.master-eks-node.name
  desired_capacity                            = var.desired_num_master_nodes
  instance_type                               = var.master_node_instante_type
  min_size                                    = var.min_num_master_nodes
  max_size                                    = var.max_num_master_nodes
  ssh_keyname                                 = aws_key_pair.eks-nodes-key.key_name
  environment-tag                             = var.environment-tag
  node_role_iam_arn                           = aws_iam_role.worker-iam.arn
  ssh_sg_id                                   = aws_security_group.worker_ssg_sg.id
}

# Start service group nodes

module "service-node-workers" {
  source                                      = "./worker-module"
  worker-asg-name                             = "service-node-workers"
  sym-search-subnet-ids                       = aws_subnet.sym-search-subnet.*.id
  cluster-name                                = aws_eks_cluster.master-eks-node.name
  desired_capacity                            = var.desired_num_service_nodes
  instance_type                               = var.service_node_instante_type
  min_size                                    = var.min_num_service_nodes
  max_size                                    = var.max_num_service_nodes
  ssh_keyname                                 = aws_key_pair.eks-nodes-key.key_name
  environment-tag                             = var.environment-tag
  node_role_iam_arn                           = aws_iam_role.worker-iam.arn
  ssh_sg_id                                   = aws_security_group.worker_ssg_sg.id
}
