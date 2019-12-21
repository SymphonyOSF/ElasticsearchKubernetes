#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 ES_CLUSTER_NAME"
    exit 1
fi

export ES_CLUSTER_NAME="$1"
 go test -timeout 60m -run TestEKSCluster -count=1
