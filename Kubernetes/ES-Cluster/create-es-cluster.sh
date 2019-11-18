#!/usr/bin/env bash

# $1: Input to verify
function verify_input_is_number() {
    if [[ ! $1 =~ ^[0-9]+$ ]] ; then
        echo "Error, expected a number"
        echo "Cancelling execution."
        exit -1;
    fi
}

#Get desired number of master nodes
echo "Master nodes count (integer)"
read -r -p "Input: " input
verify_input_is_number ${input}
MASTER_NODE_COUNT=${input}

#Get desired number of data nodes
echo "Data nodes count (integer)"
read -r -p "Input: " input
verify_input_is_number ${input}
DATA_NODE_COUNT=${input}

#Get desired amount of storage per instance
echo "Disk per data node (integer in Gigabytes)"
read -r -p "Input: " input
verify_input_is_number ${input}
DISK_PER_NODE_IN_GB=${input}

#Generate cluster name with random suffix
CLUSTER_NAME=symsearch-$(openssl rand -hex 2)

#Create SSL secret for the cluster
#kubectl create secret generic "$CLUSTER_NAME-certificate" --from-file=tls.crt=./Certificate/cert.pem --from-file=tls.key=./Certificate/key.key --from-file=ca.crt=./Certificate/ca.pem

#Generate ES and Kibana resource file from the template.
NIL=0
ytt --data-value "cluster_name=$CLUSTER_NAME" \
     --data-value "node_configuration.master.count=$MASTER_NODE_COUNT" \
     --data-value "node_configuration.data.count=$DATA_NODE_COUNT" \
     --data-value "node_configuration.data.storage_size=${DISK_PER_NODE_IN_GB}G" \
     -f ./templates/ >> "$CLUSTER_NAME.yml"

#Apply generated resource file on K8S
kubectl apply -f "$CLUSTER_NAME.yml"

echo "Your new cluster is called: ${CLUSTER_NAME}"
echo "Password for elastic user:"
kubectl get secret "$CLUSTER_NAME-es-elastic-user" -o=jsonpath='{.data.elastic}' | base64 --decode
echo ""
