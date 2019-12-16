locals {
  office_ssh_sg_id = aws_security_group.node_ssh[0] != null ? aws_security_group.node_ssh[0].id : null
  ssh_sg_id_list = compact(concat([local.office_ssh_sg_id], var.ssh_sg_id_list))
}
