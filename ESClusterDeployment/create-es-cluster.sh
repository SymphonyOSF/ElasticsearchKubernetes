#!/usr/bin/env bash
set -e
cd "${0%/*}"
# Bold and normal font modifiers
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

# Trap always the last command executed
trap 'previous_command=$this_command; this_command=$BASH_COMMAND' DEBUG
#trap all errors
trap 'catch $?' EXIT
catch() {
  if [[ "$1" != "0" ]]; then
    echo "${BOLD}\"${previous_command}\" command failed with exit code $1.${NORMAL}"
  fi
}

#Get desired cluster name
read -r -p "${BOLD}Enter cluster name (Unique and MUST conform with dns naming conventions):${NORMAL} " CLUSTER_NAME

#Generate ES and Kibana resource file from the template.
ytt --data-value "cluster_name=$CLUSTER_NAME" \
    -f https://raw.githubusercontent.com/SymphonyOSF/ElasticsearchKubernetes/master/ESClusterDeployment/templates/es-cluster.yml \
    -f https://raw.githubusercontent.com/SymphonyOSF/ElasticsearchKubernetes/master/ESClusterDeployment/templates/kibana.yml \
    -f ./cluster_template.yml \
     >> "$CLUSTER_NAME.yml"

#Apply generated resource file on K8S, this will create the Elastic+Kubernetes resources
kubectl apply -f "$CLUSTER_NAME.yml"
echo "Waiting 10s to retrieve cluster information..."
sleep 10
echo "${BOLD}New cluster name:${NORMAL} ${CLUSTER_NAME}"
echo "${BOLD}Password for elastic user:${NORMAL} $(kubectl get secret "$CLUSTER_NAME-es-elastic-user" -o=jsonpath='{.data.elastic}' | base64 --decode)"


echo "Waiting 10s to retrieve DNS information..."
sleep 10
echo "${BOLD}Elastic ELB DNS:${NORMAL} $(kubectl get svc/"${CLUSTER_NAME}"-es-http -o json | jq .status.loadBalancer.ingress[0].hostname)"
echo "${BOLD}Kibana ELB DNS: ${NORMAL} $(kubectl get svc/kibana-"${CLUSTER_NAME}"-kb-http -o json | jq .status.loadBalancer.ingress[0].hostname)"
echo "${BOLD}You can start querying the services in 2-3 minutes ${NORMAL}"
echo "Finished cluster creation successfully."
