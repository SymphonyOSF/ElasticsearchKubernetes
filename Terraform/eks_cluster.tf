module "eks_cluster" {
  source                  = "./modules/eks_cluster"
  cluster_name            = var.cluster_name
  subnet_list             = module.eks_network_module.subnet_list
  environment_tag         = var.environment_tag
  vpc_id                  = module.eks_network_module.vpc_id
}
