module "eks_network_module" {
  source                  = "../modules/eks_network"
  cluster_name            = var.cluster_name
  environment_tag         = var.environment_tag
  num_subnets             = var.num_subnets
  existing_vpc_id         = var.network.vpc_id
  subnet_id_list          = var.network.subnet_id_list
}

module "eks_cluster" {
  source                  = "../modules/eks_cluster"
  cluster_name            = var.cluster_name
  subnet_id_list          = module.eks_network_module.subnet_id_list
  environment_tag         = var.environment_tag
  vpc_id                  = module.eks_network_module.vpc_id
}

module "iam" {
  source                  = "../modules/iam"
  eks_cluster_name        = module.eks_cluster.eks_cluster_name
  eks_cluster_arn         = module.eks_cluster.eks_cluster_arn
}

resource "aws_key_pair" "eks_nodes_key" {
  key_name   = "${var.cluster_name}_ssh_key"
  public_key = var.public_key
}

//Creates N(count) data node groups, each on a dedicated AZ.
module "data_node_workers" {
  source                                      = "../modules/eks_node_group"
  worker_asg_name                             = "data_node_workers"
  subnet_id_list                              = module.eks_network_module.subnet_id_list
  cluster_name                                = module.eks_cluster.eks_cluster_name
  desired_capacity                            = var.desired_num_data_nodes
  instance_type                               = var.data_node_instante_type
  min_size                                    = var.min_num_data_nodes
  max_size                                    = var.max_num_data_nodes
  ssh_keyname                                 = aws_key_pair.eks_nodes_key.key_name
  environment_tag                             = var.environment_tag
  node_role_iam_arn                           = module.iam.worker_role_arn
  vpc_id                                      = module.eks_network_module.vpc_id
  enable_ssh_access                           = var.enable_ssh_access
  ssh_sg_id_list                              = local.ssh_sg_id_list
  single_az                                   = true
  node_group_count                            = var.num_data_node_groups
}

module "master_node_workers" {
  source                                      = "../modules/eks_node_group"
  worker_asg_name                             = "master_node_workers"
  subnet_id_list                              = module.eks_network_module.subnet_id_list
  cluster_name                                = module.eks_cluster.eks_cluster_name
  desired_capacity                            = var.desired_num_master_nodes
  instance_type                               = var.master_node_instante_type
  min_size                                    = var.min_num_master_nodes
  max_size                                    = var.max_num_master_nodes
  ssh_keyname                                 = aws_key_pair.eks_nodes_key.key_name
  environment_tag                             = var.environment_tag
  node_role_iam_arn                           = module.iam.worker_role_arn
  vpc_id                                      = module.eks_network_module.vpc_id
  enable_ssh_access                           = var.enable_ssh_access
  ssh_sg_id_list                              = local.ssh_sg_id_list
  single_az                                   = false
}

module "service_node_workers" {
  source                                      = "../modules/eks_node_group"
  worker_asg_name                             = "service_node_workers"
  subnet_id_list                              = module.eks_network_module.subnet_id_list
  cluster_name                                = module.eks_cluster.eks_cluster_name
  desired_capacity                            = var.desired_num_service_nodes
  instance_type                               = var.service_node_instante_type
  min_size                                    = var.min_num_service_nodes
  max_size                                    = var.max_num_service_nodes
  ssh_keyname                                 = aws_key_pair.eks_nodes_key.key_name
  environment_tag                             = var.environment_tag
  node_role_iam_arn                           = module.iam.worker_role_arn
  vpc_id                                      = module.eks_network_module.vpc_id
  enable_ssh_access                           = var.enable_ssh_access
  ssh_sg_id_list                              = local.ssh_sg_id_list
  single_az                                   = false
}

resource "aws_security_group" "node_ssh" {
  name        = "${var.cluster_name}_office_ssh_sg"
  description = "Security group for allowing ssh from the office"
  vpc_id      = module.eks_network_module.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["64.79.115.2/32","208.184.224.194/32"]
  }
}
