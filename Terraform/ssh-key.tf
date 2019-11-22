resource "aws_key_pair" "eks-nodes-key" {
  key_name   = "${var.cluster-name}-ssh-key"
  public_key = var.public-key
}
