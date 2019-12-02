locals {
  ssh_sg_id_list = compact(concat([aws_security_group.node_ssh.id], var.ssh_sg_id_list))
}

//Creates N(count) data node groups, each on a dedicated AZ.
module "data_node_workers" {
  source                                      = "./modules/eks_node_group"
  worker_asg_name                             = "data_node_workers"
  subnet_ids                                  = module.eks_network_module.subnet_list.*.id
  cluster_name                                = module.eks_cluster.eks_cluster_name
  desired_capacity                            = var.desired_num_data_nodes
  instance_type                               = var.data_node_instante_type
  min_size                                    = var.min_num_data_nodes
  max_size                                    = var.max_num_data_nodes
  ssh_keyname                                 = aws_key_pair.eks_nodes_key.key_name
  environment_tag                             = var.environment_tag
  node_role_iam_arn                           = aws_iam_role.worker.arn
  vpc_id                                      = module.eks_network_module.vpc_id
  enable_ssh_access                           = var.enable_ssh_access
  ssh_sg_id_list                              = local.ssh_sg_id_list
  single_az                                   = true
  node_group_count                            = var.num_data_node_groups
}

module "master_node_workers" {
  source                                      = "./modules/eks_node_group"
  worker_asg_name                             = "master_node_workers"
  subnet_ids                                  = module.eks_network_module.subnet_list.*.id
  cluster_name                                = module.eks_cluster.eks_cluster_name
  desired_capacity                            = var.desired_num_master_nodes
  instance_type                               = var.master_node_instante_type
  min_size                                    = var.min_num_master_nodes
  max_size                                    = var.max_num_master_nodes
  ssh_keyname                                 = aws_key_pair.eks_nodes_key.key_name
  environment_tag                             = var.environment_tag
  node_role_iam_arn                           = aws_iam_role.worker.arn
  vpc_id                                      = module.eks_network_module.vpc_id
  enable_ssh_access                           = var.enable_ssh_access
  ssh_sg_id_list                              = local.ssh_sg_id_list
  single_az                                   = false
}

module "service_node_workers" {
  source                                      = "./modules/eks_node_group"
  worker_asg_name                             = "service_node_workers"
  subnet_ids                                  = module.eks_network_module.subnet_list.*.id
  cluster_name                                = module.eks_cluster.eks_cluster_name
  desired_capacity                            = var.desired_num_service_nodes
  instance_type                               = var.service_node_instante_type
  min_size                                    = var.min_num_service_nodes
  max_size                                    = var.max_num_service_nodes
  ssh_keyname                                 = aws_key_pair.eks_nodes_key.key_name
  environment_tag                             = var.environment_tag
  node_role_iam_arn                           = aws_iam_role.worker.arn
  vpc_id                                      = module.eks_network_module.vpc_id
  enable_ssh_access                           = var.enable_ssh_access
  ssh_sg_id_list                              = local.ssh_sg_id_list
  single_az                                   = false
}
