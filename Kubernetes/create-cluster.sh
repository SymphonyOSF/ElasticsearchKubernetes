#!/usr/bin/env bash
aws eks update-kubeconfig --name $1

true | tee ./config_map_aws_auth.yml
cd ../Terraform/
terraform output config_map_aws_auth >> ../Kubernetes/config_map_aws_auth.yml
cd ../Kubernetes

kubectl apply -f ./config_map_aws_auth.yml
kubectl apply -f ./all-in-one.yaml
kubectl apply -f ./standard-storageclass.yml
kubectl apply -f ./es-cluster.yml
