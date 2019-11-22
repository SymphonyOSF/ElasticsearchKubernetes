module "data-node-workers" {
  source                                      = "./modules/eks-node-group"
  worker-asg-name                             = "data-node-workers"
  sym-search-subnet-ids                       = [module.eks_network_module.subnet_list.0.id]
  cluster-name                                = module.eks_cluster.eks_cluster_name
  desired_capacity                            = var.desired_num_data_nodes
  instance_type                               = var.data_node_instante_type
  min_size                                    = var.min_num_data_nodes
  max_size                                    = var.max_num_data_nodes
  ssh_keyname                                 = aws_key_pair.eks-nodes-key.key_name
  environment-tag                             = var.environment-tag
  node_role_iam_arn                           = aws_iam_role.worker-iam.arn
  vpc_id                                      = module.eks_network_module.vpc_id
}

module "master-node-workers" {
  source                                      = "./modules/eks-node-group"
  worker-asg-name                             = "master-node-workers"
  sym-search-subnet-ids                       = module.eks_network_module.subnet_list.*.id
  cluster-name                                = module.eks_cluster.eks_cluster_name
  desired_capacity                            = var.desired_num_master_nodes
  instance_type                               = var.master_node_instante_type
  min_size                                    = var.min_num_master_nodes
  max_size                                    = var.max_num_master_nodes
  ssh_keyname                                 = aws_key_pair.eks-nodes-key.key_name
  environment-tag                             = var.environment-tag
  node_role_iam_arn                           = aws_iam_role.worker-iam.arn
  vpc_id                                      = module.eks_network_module.vpc_id
}

module "service-node-workers" {
  source                                      = "./modules/eks-node-group"
  worker-asg-name                             = "service-node-workers"
  sym-search-subnet-ids                       = module.eks_network_module.subnet_list.*.id
  cluster-name                                = module.eks_cluster.eks_cluster_name
  desired_capacity                            = var.desired_num_service_nodes
  instance_type                               = var.service_node_instante_type
  min_size                                    = var.min_num_service_nodes
  max_size                                    = var.max_num_service_nodes
  ssh_keyname                                 = aws_key_pair.eks-nodes-key.key_name
  environment-tag                             = var.environment-tag
  node_role_iam_arn                           = aws_iam_role.worker-iam.arn
  vpc_id                                      = module.eks_network_module.vpc_id
}
