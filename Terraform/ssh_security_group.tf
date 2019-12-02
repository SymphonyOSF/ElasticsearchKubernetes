resource "aws_security_group" "node_ssh" {
  name        = "office_ssh_sg"
  description = "Security group for allowing ssh to worker nodes"
  vpc_id      = module.eks_network_module.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["64.79.115.2/32","208.184.224.194/32"]
  }
}
