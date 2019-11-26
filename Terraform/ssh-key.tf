resource "aws_key_pair" "eks_nodes_key" {
  key_name   = "${var.cluster_name}_ssh_key"
  public_key = var.public_key
}
