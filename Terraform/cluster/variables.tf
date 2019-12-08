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

variable "num_subnets" {
  description = "Number of subnets be created inside the VPC, each on a single AZ"
  type        = number
}

variable "data_node_instante_type" {
  description = "EC2 instance type to be used on the Elasticsearch data nodes"
  type        = string
}

variable "num_data_node_groups" {
  description = "Number of node groups to be created. Each on a single availability zone."
  type        = number
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

variable "enable_ssh_access" {
  description = "Activates/Deactivates SSH access to the nodes (by default allows office access)"
  type        = bool
}

variable "ssh_sg_id_list" {
  description = "In addition to enabling/disabling SSH from the office, you can add extra SG ids that will have access to the 22 port on all the nodes."
  default     = [""]
  type        = list(string)
}

variable "network" {
  description = "Define both to deploy the EKS Cluster + Worker nodes on top of that VPC+subnets. Don't define to create a new VPC+subnets. See important info: https://perzoinc.atlassian.net/wiki/spaces/SEARCH/pages/646057959/Using+existing+VPC+and+subnets"
  type        = object({
    vpc_id    = string
    subnet_id_list = list(string)
  })
  default     = {
    vpc_id: null
    subnet_id_list: null
  }
}
