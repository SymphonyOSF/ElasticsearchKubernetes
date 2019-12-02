environment_tag             = "dev"
region                      = "us-east-1"
cluster_name                = "sym-search-dev-shared"
public_key                  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCXx55LPxZMkO+KNYovPrF6ghA5apRWqS+F5Uutz1Vq5EpbgJiclZN1QvExxAdGoyue0mT3EGrWcww4X1RuAUFc7yQFYaBgfVpUm4P5HBnO695WMDYYum1Dy+Tkfn/NoK9+XxY6nMSxT1R/tODcyId+boaFeAHNH//8FyE57P6JSQq/UpWWCKcV0+Gjo4uio8WeSS0hwGbchzxbB+7XQw0JmWFFPqq8DRxZUb7sesAIUknUIf7lDzQ+juagIpQ9SO7lr35G2VQLPJm8dB7djwx9vsFzw0CoMZZgQH/k2LHYJzz0gtzWCVT2lQ1RFsaKGnaCuPNIHnOm2q0MRLhILH2F"
num_availability_zones      = 2

//Data nodes group 1
data_node_instante_type     = "c5.xlarge"
min_num_data_nodes          = 1
max_num_data_nodes          = 60
desired_num_data_nodes      = 1

//Master nodes
master_node_instante_type   = "c5.large"
min_num_master_nodes        = 1
max_num_master_nodes        = 30
desired_num_master_nodes    = 1

//Service nodes
service_node_instante_type  = "t3.small"
min_num_service_nodes       = 1
max_num_service_nodes       = 30
desired_num_service_nodes   = 1

enable_ssh_access           = true