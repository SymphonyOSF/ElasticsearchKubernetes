module "eks_cluster" {
  source = "../../cluster"

  environment_tag             = "dev"
  region                      = var.region
  cluster_name                = "sym-search-dev-vpc-test"
  public_key                  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCXx55LPxZMkO+KNYovPrF6ghA5apRWqS+F5Uutz1Vq5EpbgJiclZN1QvExxAdGoyue0mT3EGrWcww4X1RuAUFc7yQFYaBgfVpUm4P5HBnO695WMDYYum1Dy+Tkfn/NoK9+XxY6nMSxT1R/tODcyId+boaFeAHNH//8FyE57P6JSQq/UpWWCKcV0+Gjo4uio8WeSS0hwGbchzxbB+7XQw0JmWFFPqq8DRxZUb7sesAIUknUIf7lDzQ+juagIpQ9SO7lr35G2VQLPJm8dB7djwx9vsFzw0CoMZZgQH/k2LHYJzz0gtzWCVT2lQ1RFsaKGnaCuPNIHnOm2q0MRLhILH2F"
  num_subnets                 = 2

  //Data nodes group
  num_data_node_groups        = 2
  data_node_instante_type     = "t3.large"
  min_num_data_nodes          = 1
  max_num_data_nodes          = 60
  desired_num_data_nodes      = 1

  //Master nodes
  master_node_instante_type   = "c5.large"
  min_num_master_nodes        = 1
  max_num_master_nodes        = 30
  desired_num_master_nodes    = 1

  //Service nodes
  service_node_instante_type  = "t3.small"
  min_num_service_nodes       = 1
  max_num_service_nodes       = 30
  desired_num_service_nodes   = 1

  enable_ssh_access           = true

  network = {
    vpc_id          = var.vpc_id
    subnet_id_list  = var.subnet_id_list
  }
}

###########!! DO NOT REMOVE THIS !!############
terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    encrypt = true
  }
}

# https://www.terraform.io/docs/providers/aws/index.html
provider "aws" {
  version = ">= 2.38.0"
  region = var.region
}

output "eks_cluster_output" {
  value = module.eks_cluster
}

variable "region" {
  description = "AWS region to deploy the cluster in"
}

variable "vpc_id" {
  default = "vpc-0b9a092701e6fba2f"
}

variable "subnet_id_list" {
  default = ["subnet-09b866c484fbc9245", "subnet-0ee2bddf7993c3055"]
}

output "REMINDER" {
  value = "\n**************************************************\n**************************************************\nREMEMBER TO BOOTSTRAP THE EKS CLUSTER BEFORE YOU START DEPLOYING ELASTICSEARCH CLUSTERS\n**************************************************\n**************************************************\n"
}
