locals {
  ssh_sg_id_list = compact(concat([aws_security_group.node_ssh.id], var.ssh_sg_id_list))
}
