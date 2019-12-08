variable "worker_asg_name" {}

variable "subnet_id_list" {}

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

variable "node_group_count" {
  type        = number
  description = "Number of nodegroups to create, 1 by default"
  default     = 1
}

variable "single_az" {
  type        = bool
  description = "Indicates whether the nodegroup should be spawned on a single AZ"
}

variable "ssh_sg_id_list" {
  description = "List containing the IDs of the security groups allowed for SSH, by default, empty = no ssh access from anywhere."
  type        = list(string)
}
