#!/usr/bin/env bash
set -e

# Trap always the last command executed
trap 'previous_command=$this_command; this_command=$BASH_COMMAND' DEBUG
#trap all errors
trap 'catch $?' EXIT
catch() {
  if [[ "$1" != "0" ]]; then
    echo "${BOLD}\"${previous_command}\" command failed with exit code $1.${NORMAL}"
  fi
}

# Bold and normal font modifiers
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

#Test kubectl connection
kubectl auth can-i '*' '*' >/dev/null

#Get cluster name
read -r -p "${BOLD}Enter cluster name to delete:${NORMAL} " CLUSTER_NAME

set +e
kubectl get Elasticsearch/${CLUSTER_NAME} >/dev/null 2>&1
if [[ $? != 0 ]]; then
    echo "${BOLD}************* ERROR ************* ${NORMAL}"
    echo "The cluster specified doesn't exist"
    echo "This is the list of existing Elastic clusters:"
    kubectl get Elasticsearch -o=custom-columns=CLUSTER_NAME:.metadata.name
    echo "${BOLD}************* ERROR ************* ${NORMAL}"
    exit 0;
fi
set -e

#Remove Elasticsearch
kubectl delete Elasticsearch/${CLUSTER_NAME}

#Remove Kibana
kubectl delete Kibana/kibana-${CLUSTER_NAME}

echo "Successfully deleted ${CLUSTER_NAME}"
