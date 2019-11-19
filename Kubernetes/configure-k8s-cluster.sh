#!/usr/bin/env bash
#Change kubectl authentication conf to match the K8S master
aws eks update-kubeconfig --name $1

#Regenerate the config_map file for K8S to discover worker nodes
true | tee ./config_map_aws_auth.yml
cd ../Terraform/
terraform output config_map_aws_auth >> ../Kubernetes/config_map_aws_auth.yml
cd ../Kubernetes

#Apply config_map file to K8S, this will allow the control plane discover worker nodes
kubectl apply -f ./config_map_aws_auth.yml

#Install AWS auto-scaler
kubectl apply -f ./cluster-autoscaler-autodiscover.yaml
#Prevent from automatically taking down the node holding the auto-scaler pod
kubectl -n kube-system annotate deployment.apps/cluster-autoscaler cluster-autoscaler.kubernetes.io/safe-to-evict="false"

#Set the image to the current K8S version
kubectl -n kube-system set image deployment.apps/cluster-autoscaler cluster-autoscaler=k8s.gcr.io/cluster-autoscaler:v1.14.6

#Bring up DNS mapping service
#kubectl apply -f ./DNS/external_dns.yaml

#---------- Kubernetes Dashboard ------------
# Run the Kubernetes Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta4/aio/deploy/recommended.yaml
# Create dashboard admin user and attach admin role to it
kubectl apply -f ./Dashboard/dashboard-user.yaml

#-------- /End Kubernetes Dashboard ----------

#Configure the elastic operator
kubectl apply -f ./all-in-one.yaml
