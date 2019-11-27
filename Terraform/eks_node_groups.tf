module "data_node_workers_1" {
  source                                      = "./modules/eks_node_group"
  worker_asg_name                             = "data_node_workers_1"
  sym_search_subnet_ids                       = [module.eks_network_module.subnet_list.0.id]
  cluster_name                                = module.eks_cluster.eks_cluster_name
  desired_capacity                            = var.desired_num_data_nodes
  instance_type                               = var.data_node_instante_type
  min_size                                    = var.min_num_data_nodes
  max_size                                    = var.max_num_data_nodes
  ssh_keyname                                 = aws_key_pair.eks_nodes_key.key_name
  environment_tag                             = var.environment_tag
  node_role_iam_arn                           = aws_iam_role.worker.arn
  vpc_id                                      = module.eks_network_module.vpc_id
}

module "data_node_workers_2" {
  source                                      = "./modules/eks_node_group"
  worker_asg_name                             = "data_node_workers_2"
  sym_search_subnet_ids                       = [module.eks_network_module.subnet_list.1.id]
  cluster_name                                = module.eks_cluster.eks_cluster_name
  desired_capacity                            = var.desired_num_data_nodes
  instance_type                               = var.data_node_instante_type
  min_size                                    = var.min_num_data_nodes
  max_size                                    = var.max_num_data_nodes
  ssh_keyname                                 = aws_key_pair.eks_nodes_key.key_name
  environment_tag                             = var.environment_tag
  node_role_iam_arn                           = aws_iam_role.worker.arn
  vpc_id                                      = module.eks_network_module.vpc_id
}

module "master_node_workers" {
  source                                      = "./modules/eks_node_group"
  worker_asg_name                             = "master_node_workers"
  sym_search_subnet_ids                       = module.eks_network_module.subnet_list.*.id
  cluster_name                                = module.eks_cluster.eks_cluster_name
  desired_capacity                            = var.desired_num_master_nodes
  instance_type                               = var.master_node_instante_type
  min_size                                    = var.min_num_master_nodes
  max_size                                    = var.max_num_master_nodes
  ssh_keyname                                 = aws_key_pair.eks_nodes_key.key_name
  environment_tag                             = var.environment_tag
  node_role_iam_arn                           = aws_iam_role.worker.arn
  vpc_id                                      = module.eks_network_module.vpc_id
}

module "service_node_workers" {
  source                                      = "./modules/eks_node_group"
  worker_asg_name                             = "service_node_workers"
  sym_search_subnet_ids                       = module.eks_network_module.subnet_list.*.id
  cluster_name                                = module.eks_cluster.eks_cluster_name
  desired_capacity                            = var.desired_num_service_nodes
  instance_type                               = var.service_node_instante_type
  min_size                                    = var.min_num_service_nodes
  max_size                                    = var.max_num_service_nodes
  ssh_keyname                                 = aws_key_pair.eks_nodes_key.key_name
  environment_tag                             = var.environment_tag
  node_role_iam_arn                           = aws_iam_role.worker.arn
  vpc_id                                      = module.eks_network_module.vpc_id
}
