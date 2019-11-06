variable "region" {
  default = "us-east-1"
}

variable "cluster-name" {
  default = "sym-eks"
  type    = "string"
}

variable "public-key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCXx55LPxZMkO+KNYovPrF6ghA5apRWqS+F5Uutz1Vq5EpbgJiclZN1QvExxAdGoyue0mT3EGrWcww4X1RuAUFc7yQFYaBgfVpUm4P5HBnO695WMDYYum1Dy+Tkfn/NoK9+XxY6nMSxT1R/tODcyId+boaFeAHNH//8FyE57P6JSQq/UpWWCKcV0+Gjo4uio8WeSS0hwGbchzxbB+7XQw0JmWFFPqq8DRxZUb7sesAIUknUIf7lDzQ+juagIpQ9SO7lr35G2VQLPJm8dB7djwx9vsFzw0CoMZZgQH/k2LHYJzz0gtzWCVT2lQ1RFsaKGnaCuPNIHnOm2q0MRLhILH2F"
}