#!/usr/bin/env bash
set -e
#CD into the directory containing this script
cd "${0%/*}"

# Bold and normal font modifiers
bold=$(tput bold)
normal=$(tput sgr0)

# Trap always the last command executed
trap 'previous_command=$this_command; this_command=$BASH_COMMAND' DEBUG

#trap all errors
trap 'catch $?' EXIT
catch() {
  if [[ "$1" != "0" ]]; then
    echo "${bold}\"${previous_command}\" command failed with exit code $1.${normal}"
  fi
}

#Regenerate the config_map file for K8S to discover worker nodes
#Get cluster_name and service_instance_type from terraform output.
true | tee ./config_map_aws_auth.yml
terraform output -json eks_cluster_output | jq -r .config_map_aws_auth >> ./Kubernetes/config_map_aws_auth.yml
SERVICE_INSTANCE_TYPE=$(terraform output -json eks_cluster_output | jq -r .service_instance_type)
CLUSTER_NAME=$(terraform output -json eks_cluster_output | jq -r .cluster_name)
cd ./Kubernetes

#Change kubectl authentication conf to match the K8S master
aws eks update-kubeconfig --name "${CLUSTER_NAME}"

#Apply config_map file to K8S, this will allow the control plane discover worker nodes
kubectl apply -f ./config_map_aws_auth.yml

#Install AWS auto-scaler. Replace cluster_name and service_instance_type
sed "s/NEW_CLUSTER_NAME/${CLUSTER_NAME}/g" cluster-autoscaler-autodiscover.yaml \
    | sed -E "s/SERVICE_INSTANCE_TYPE/${SERVICE_INSTANCE_TYPE}/g" \
    | kubectl apply -f -


#Prevent from automatically taking down the node holding the auto-scaler pod
kubectl -n kube-system annotate --overwrite deployment.apps/cluster-autoscaler cluster-autoscaler.kubernetes.io/safe-to-evict="false"

#Set the image to match the running K8S version
kubectl -n kube-system set image deployment.apps/cluster-autoscaler cluster-autoscaler=k8s.gcr.io/cluster-autoscaler:v1.14.6

#Bring up DNS mapping service
#kubectl apply -f ./DNS/external_dns.yaml

#---------- Kubernetes Dashboard ------------
# Run the Kubernetes Dashboard, 2.0.0-beta1
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta1/aio/deploy/recommended.yaml
# Create dashboard admin user and attach admin role to it
kubectl apply -f ./Dashboard/dashboard-user.yaml

#-------- /End Kubernetes Dashboard ----------

#Configure the elastic operator. Replace instance_type and service_instance_type
sed "s/SERVICE_INSTANCE_TYPE/${SERVICE_INSTANCE_TYPE}/g" all-in-one.yaml \
    | kubectl apply -f -
