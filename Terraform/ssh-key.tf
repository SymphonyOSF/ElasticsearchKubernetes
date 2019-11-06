resource "aws_key_pair" "eks-nodes-key" {
  key_name   = "ssh-key"
  public_key = var.public-key
}