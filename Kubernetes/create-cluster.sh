#!/usr/bin/env bash
aws eks update-kubeconfig --name $1

#true | tee data_map_aws_auth.yml
#true | tee master_map_aws_auth.yml
#cd ../Terraform/
#terraform output data-note-config-map >> ../Kubernetes/data_map_aws_auth.yml
##terraform output master-note-config-map >> ../Kubernetes/master_map_aws_auth.yml
#
#cd ../Kubernetes
kubectl apply -f ./data_map_aws_auth.yml
kubectl apply -f ./all-in-one.yaml
kubectl apply -f ./standard-storageclass.yml
kubectl apply -f ./es-cluster.yml
