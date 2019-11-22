module "eks_cluster" {
  source                  = "./modules/eks-cluster"
  cluster_name            = var.cluster-name
  subnet_list             = module.eks_network_module.subnet_list
  environment_tag         = var.environment-tag
  vpc_id                  = module.eks_network_module.vpc_id
}
