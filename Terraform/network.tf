module "eks_network_module" {
  source                  = "./modules/network"
  cluster_name            = var.cluster-name
  environment_tag         = var.environment-tag
  num_availability_zones  = var.num_availability_zones
}