variable "environment_tag" {}

variable "cluster_name" {}

variable "num_subnets" {
  description = "Number of subnets to create, each on a single and different AZ"
  type        = number
}

variable "subnet_id_list" {}

variable "existing_vpc_id" {}
