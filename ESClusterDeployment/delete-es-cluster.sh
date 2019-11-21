#!/usr/bin/env bash

CLUSTER_NAME=$1

if [ ! -f "./${CLUSTER_NAME}" ]; then
    echo "File not found!"
    echo "You must pass as a parameter the yaml file with the name of your cluster in the current directory."
    echo "E.g. ./delete-es-cluster.sh symsearch-1d2f.yml"
    exit 1;
fi

# Delete the secret containing the SSL certificate
#kubectl delete secret ${CLUSTER_NAME}

#Remove elasticsearch and kibana deployments/sts based on the name given as parameter.
kubectl delete -f "./${CLUSTER_NAME}"

if [[ $0 == 0 ]]; then
    rm -rf "./${CLUSTER_NAME}"
fi;