#!/usr/bin/env bash
# Exit when any command fails
set -e

# Trap always the last command executed
trap 'previous_command=$this_command; this_command=$BASH_COMMAND' DEBUG

#trap all errors
trap 'catch $?' EXIT
catch() {
  if [[ "$1" != "0" ]]; then
    echo "${bold}\"${previous_command}\" command on failed with exit code $1.${normal}"
  fi
}

# Bold and normal font modifiers
bold=$(tput bold)
normal=$(tput sgr0)

#Configure aws cli
aws configure

read -r -p "Enter EKS cluster name [As configured on terraform]: " CLUSTER_NAME
read -r -p "Enter the role ARN [Obtained from the terraform output]: " ROLE_ARN
#Configure .kubeconfig for kubectl to point to the cluster.
aws eks update-kubeconfig --name ${CLUSTER_NAME} --role-arn ${ROLE_ARN}

#Verify that the authentication was successful
kubectl auth can-i '*' '*'

echo "Successfully configured kubectl"
