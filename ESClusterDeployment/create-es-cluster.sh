#!/usr/bin/env bash
set -e

#Test kubectl connection
kubectl auth can-i '*' '*' >/dev/null

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

# $1: Cluster name
# $2: (Optional) contains environment name: dev
function create_cluster() {
    CLUSTER_NAME=$1
    #Verify there is no ES cluster with the same name
    set +e
    kubectl get Elasticsearch/${CLUSTER_NAME} >/dev/null 2>&1
    if [[ $? == 0 ]]; then
        echo "${BOLD}************* ERROR ************* ${NORMAL}"
        echo "An Elastic cluster with the same name already exists"
        echo "Use a different cluster name"
        echo "${BOLD}************* ERROR ************* ${NORMAL}"
        exit 1;
    fi
    set -e

#    Initialize template files
    ELASTIC_TEMPLATE=https://raw.githubusercontent.com/SymphonyOSF/ElasticsearchKubernetes/master/ESClusterDeployment/templates/es-cluster.yml
    KIBANA_TEMPLATE=https://raw.githubusercontent.com/SymphonyOSF/ElasticsearchKubernetes/master/ESClusterDeployment/templates/kibana.yml
    if [[ -f "./templates/es-cluster.yml" ]]; then
        echo "Using local ES template file (development mode)"
        ELASTIC_TEMPLATE=./templates/es-cluster.yml
    fi
    if [[ -f "./templates/kibana.yml" ]]; then
        echo "Using local Kibana template file (development mode)"
        KIBANA_TEMPLATE=./templates/kibana.yml
    fi

    #Generate ES and Kibana resource file from the template.
    #Finally, create (apply) the K8S resources
    ytt --data-value "cluster_name=$CLUSTER_NAME" \
        -f ${ELASTIC_TEMPLATE} \
        -f ${KIBANA_TEMPLATE} \
        -f ./cluster_template.yml \
        | kubectl apply -f -

    #Apply generated resource file on K8S, this will create the Elastic+Kubernetes resources
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
}

if [[ $1 != "-y" || -z "$2" ]]; then
    #Get desired cluster name
    read -r -p "${BOLD}Enter cluster name (Unique and MUST conform with dns naming conventions):${NORMAL} " CLUSTER_NAME
    create_cluster ${CLUSTER_NAME} "dev"
else
    CLUSTER_NAME=$2
    create_cluster ${CLUSTER_NAME}
fi
