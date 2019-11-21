//# This data source is included for ease of sample architecture deployment
//# and can be swapped out as necessary.
//data "aws_region" "current" {}
//
//# EKS currently documents this required userdata for EKS worker nodes to
//# properly configure Kubernetes applications on the EC2 instance.
//# We implement a Terraform local here to simplify Base64 encoding this
//# information into the AutoScaling Launch Configuration.
//# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
//locals {
//  worker-node-userdata = <<USERDATA
//#!/bin/bash
//set -o xtrace
//sudo swapoff -a
//sed -i '/^LimitNOFILE=*/a LimitMEMLOCK=infinity' /usr/lib/systemd/system/docker.service
//sudo systemctl daemon-reload
//sudo systemctl restart docker.service
///etc/eks/bootstrap.sh --apiserver-endpoint '${var.master-eks-node-endpoint}' --b64-cluster-ca '${var.master-eks-node-certificate-authority-data}' '${var.cluster-name}'
//USERDATA
//}
//
//resource "aws_launch_configuration" "worker-launch-conf" {
//  associate_public_ip_address = true
//  iam_instance_profile        = var.aws_iam_instance_profile_name
//  image_id                    = data.aws_ami.eks-worker.id
//  instance_type               = var.instance_type
//  name_prefix                 = var.worker-asg-name
//  security_groups             = [aws_security_group.worker-sg.id, var.central_sg_id]
//  user_data_base64            = base64encode(local.worker-node-userdata)
//  key_name                    = var.ssh_keyname
//
//  lifecycle {
//    create_before_destroy = true
//  }
//
//}