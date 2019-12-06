#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 ES_CLUSTER_NAME"
    exit 1
fi

python test_elasticsearch.py -c $1