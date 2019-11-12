#!/usr/bin/env bash
#Change kubectl authentication conf to match the K8S master
aws eks update-kubeconfig --name $1

#Regenerate the config_map file for K8S to discover worker nodes
true | tee ./config_map_aws_auth.yml
cd ../Terraform/
terraform output config_map_aws_auth >> ../Kubernetes/config_map_aws_auth.yml
cd ../Kubernetes

#Apply config_map for K8S to discover worker nodes
kubectl apply -f ./config_map_aws_auth.yml

#Install AWS auto-scaler
kubectl apply -f ./cluster-autoscaler-autodiscover.yaml
#Prevent from automatically taking down the node holding the auto-scaler pod
kubectl -n kube-system annotate deployment.apps/cluster-autoscaler cluster-autoscaler.kubernetes.io/safe-to-evict="false"

#Set the image to the current K8S version
kubectl -n kube-system set image deployment.apps/cluster-autoscaler cluster-autoscaler=k8s.gcr.io/cluster-autoscaler:v1.14.6

#Configure elastic operator
kubectl apply -f ./all-in-one.yaml
#Configure elasticsearcg cluster
kubectl apply -f ./es-cluster.yml

kubectl apply -f ./kibana.yaml
