resource "aws_key_pair" "eks-nodes-key" {
  key_name   = "ssh-key-test"
  public_key = var.public-key
}

resource "aws_security_group" "ssh-sg" {
  name        = "allow-ssh-sg"
  description = "Security group to allow ssg for all nodes in the cluster"
  vpc_id      = aws_vpc.sym-search-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["64.79.115.2/32","208.184.224.194/32"]
  }

  tags = {
    Name                                        = "elasticEksCluster"
    "Owner:team"                                = "search"
    Org                                         = "engineering"
    Customer                                    = "symphony"
    CreatedBy                                   = "terraform"
    Environment                                 = var.environment-tag
  }

}