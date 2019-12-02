module "eks_network_module" {
  source                  = "./modules/eks_network"
  cluster_name            = var.cluster_name
  environment_tag         = var.environment_tag
  num_availability_zones  = var.num_availability_zones
}