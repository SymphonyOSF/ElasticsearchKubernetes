module "eks_cluster" {
  source = "git::https://github.com/SymphonyOSF/ElasticsearchKubernetes.git//Terraform/cluster"

  environment_tag             = "dev"
  region                      = var.region
  cluster_name                = ""
  public_key                  = ""
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

//  Dev default VPC and subnets
  network = {
    vpc_id          = "vpc-a2ed6dc7"
    subnet_id_list  = ["subnet-fb30a39e", "subnet-9b20c0b0", "subnet-d32187a4"]
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

output "REMINDER" {
  value = "\n**************************************************\n**************************************************\nREMEMBER TO BOOTSTRAP THE EKS CLUSTER BEFORE YOU START DEPLOYING ELASTICSEARCH CLUSTERS\n**************************************************\n**************************************************\n"
}
