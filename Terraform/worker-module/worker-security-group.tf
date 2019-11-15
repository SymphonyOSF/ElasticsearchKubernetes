resource "aws_security_group" "worker-sg" {
  name        = "${var.worker-asg-name}-sg"
  description = "Security group for all workers in the cluster"
  vpc_id      = var.sym-search-vpc-id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                        = "terraform-eks-worker-sg"
//    IMPORTANT: There can only be one security group with this tag
    "kubernetes.io/cluster/${var.cluster-name}" =  "owned"
  }

}

resource "aws_security_group_rule" "worker-sg-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.worker-sg.id
  source_security_group_id = aws_security_group.worker-sg.id
  type                     = "ingress"
}

resource "aws_security_group_rule" "central-sg-ingress-self" {
  description              = "Allow this ASG to communicate with all other ASGs."
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.worker-sg.id
  source_security_group_id = var.central_sg_id
  type                     = "ingress"
}

//TODO: Remove in PROD
resource "aws_security_group_rule" "allow-ssh-self" {
  description              = "Allow ssh access from office IPs"
  cidr_blocks              = ["64.79.115.2/32","208.184.224.194/32"]
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker-sg.id
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker-sg-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane (K8S master)"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker-sg.id
  source_security_group_id = var.aws-security-group-master-sg-id
  type                     = "ingress"
}

//Allow SSL access from the k8s master to all the nodes
resource "aws_security_group_rule" "cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = var.aws-security-group-master-sg-id
  source_security_group_id = aws_security_group.worker-sg.id
  type                     = "ingress"
}
resource "aws_security_group_rule" "cluster-ingress-node-https-2" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker-sg.id
  source_security_group_id = var.aws-security-group-master-sg-id
  type                     = "ingress"
}

output "security_group_id" {
  value = aws_security_group.worker-sg.id
}