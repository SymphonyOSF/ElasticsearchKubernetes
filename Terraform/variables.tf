variable "environment_tag" {
  description = "Environment tag"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "cluster_name" {
  description = "Name for the EKS cluster [suggested: sym_search_dev_*]"
  type        = string
}

variable "public_key" {
  description = "Public key used for SSH connection. Format must be: ssh-rsa AAAAB3...."
  type        = string
}

variable "num_availability_zones" {
  description = "Number of availability zones to be created inside the VPC"
  type        = number
}

variable "data_node_instante_type" {
  description = "EC2 instance type to be used on the Elasticsearch data nodes"
  type        = string
}

variable "min_num_data_nodes" {
  description = "Auto scaling group min number of nodes"
  type        = number
}

variable "max_num_data_nodes" {
  description = "Auto scaling group max number of nodes"
  type        = number
}

variable "desired_num_data_nodes" {
  description = "Auto scaling group desired number of nodes"
  type        = number
}

variable "master_node_instante_type" {
  description = "EC2 instance type to be used on the Elasticsearch master nodes"
  type        = string
}

variable "min_num_master_nodes" {
  description = "Auto scaling group min number of nodes"
  type        = number
}

variable "max_num_master_nodes" {
  description = "Auto scaling group max number of nodes"
  type        = number
}

variable "desired_num_master_nodes" {
  description = "Auto scaling group desired number of nodes"
  type        = number
}

variable "service_node_instante_type" {
  description = "EC2 instance type to be used on the service nodes"
  type        = string
}

variable "min_num_service_nodes" {
  description = "Auto scaling group min number of nodes"
  type        = number
}

variable "max_num_service_nodes" {
  description = "Auto scaling group max number of nodes"
  type        = number
}

variable "desired_num_service_nodes" {
  description = "Auto scaling group desired number of nodes"
  type        = number
}
