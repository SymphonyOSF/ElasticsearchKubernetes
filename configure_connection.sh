#!/usr/bin/env bash
# Exit when any command fails
set -e
# Bold and normal font modifiers
bold=$(tput bold)
normal=$(tput sgr0)
# Trap all error calls and print error message.
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'echo "${bold}\"${last_command}\" command failed with exit code $?.${normal}"' EXIT


#Configure aws cli
echo "${bold}Important: ${normal}When prompted, enter ${bold}json ${normal}as default output format"
aws configure


read -r -p "Enter EKS cluster name [As configured on terraform]: " CLUSTER_NAME
read -r -p "Enter the role ARN [Obtained from the terraform output]: " ROLE_ARN
#Configure .kubeconfig for kubectl to point to the cluster.
aws eks update-kubeconfig --name ${CLUSTER_NAME} --role-arn ${ROLE_ARN}

kubectl auth can-i '*' '*'

echo "Successfully configured kubectl"
