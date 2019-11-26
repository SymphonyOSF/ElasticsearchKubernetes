resource "aws_security_group" "master" {
  name        = "${var.cluster_name}_eks_master_sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name            = "elasticEksCluster"
    "Owner:team"    = "search"
    Org             = "engineering"
    Customer        = "symphony"
    CreatedBy       = "terraform"
    Environment     = var.environment_tag
  }
}

resource "aws_security_group_rule" "office_ssh" {
  cidr_blocks       = ["64.79.115.2/32", "208.184.224.194/32"]
  description       = "Allow PA office to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.master.id
  to_port           = 443
  type              = "ingress"
}
