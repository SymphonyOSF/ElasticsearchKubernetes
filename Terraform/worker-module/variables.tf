variable "worker-asg-name" {
  default = ""
}

variable "master-eks-node-version" {
  default = ""
}

variable "sym-search-subnet-ids" {
  default = []
}

variable "cluster-name" {
  default = ""
}

variable "master-eks-node-endpoint" {
  default = ""
}

variable "master-eks-node-certificate-authority-data" {
  default = ""
}

variable "sym-search-vpc-id" {
  default = ""
}

variable "aws-security-group-master-sg-id" {
  default = ""
}

variable "desired_capacity" {
  default = 1
}

variable "instance_type" {
  default = "m4.2xlarge"
}

variable "max_size" {
  default = 1
}

variable "min_size" {
  default = 1
}

variable "ssh_keyname" {}
//variable "other_group_sg_id" {}

variable "aws_iam_instance_profile_name" {}