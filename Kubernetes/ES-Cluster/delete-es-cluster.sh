#!/usr/bin/env bash

kubectl delete secret my-cert

#Configure new elasticsearch cluster based on the es-cluster.yml file.
kubectl delete -f ./es-cluster.yml

#Configure kibana for that cluster.
kubectl delete -f ./kibana.yaml
