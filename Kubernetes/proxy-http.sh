#!/usr/bin/env bash
# arg1: ELASTIC cluster name
# arg2: local port number

if [ "$#" -le 1 ]; then
    echo "Number of arguments should be 2"
    exit 1
fi

PASSWORD=$(kubectl get secret "$1-es-elastic-user"  -o=jsonpath='{.data.elastic}' | base64 --decode)
echo "Password is: $PASSWORD"
kubectl port-forward "service/$1-es-http" "$2"
