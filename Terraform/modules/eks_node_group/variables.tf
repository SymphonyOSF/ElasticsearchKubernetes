variable "worker_asg_name" {}

variable "sym_search_subnet_ids" {}

variable "cluster_name" {}

variable "desired_capacity" {}

variable "instance_type" {}

variable "max_size" {}

variable "min_size" {}

variable "ssh_keyname" {}

variable "environment_tag" {}

variable "vpc_id" {}

variable "node_role_iam_arn" {}

variable "enable_ssh_access" {}

variable "ssh_sg_id_list" {
  default = []
  description = "List containing the IDs of the security groups allowed for SSH, by default, empty = no ssh access from anywhere."
  type = list(string)
}
