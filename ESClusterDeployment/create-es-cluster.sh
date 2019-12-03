#!/usr/bin/env bash

# Bold and normal font modifiers
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

#Get desired cluster name
read -r -p "${BOLD}Enter cluster name (must not be another cluster with the same name):${NORMAL} " CLUSTER_NAME

#Create SSL secret for the cluster
#kubectl create secret generic "$CLUSTER_NAME-certificate" --from-file=tls.crt=./Certificate/cert.pem --from-file=tls.key=./Certificate/key.key --from-file=ca.crt=./Certificate/ca.pem

#Generate ES and Kibana resource file from the template.
ytt --data-value "cluster_name=$CLUSTER_NAME" \
  -f ./templates/ >> "$CLUSTER_NAME.yml"

#Apply generated resource file on K8S
kubectl apply -f "$CLUSTER_NAME.yml"
echo "Retrieving information..."
sleep 10
echo "${BOLD}New cluster name:${NORMAL} ${CLUSTER_NAME}"
echo "${BOLD}Password for elastic user:${NORMAL} $(kubectl get secret "$CLUSTER_NAME-es-elastic-user" -o=jsonpath='{.data.elastic}' | base64 --decode)"
echo "Finished execution."
