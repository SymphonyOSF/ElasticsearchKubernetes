#!/usr/bin/env bash
kubectl get namespaces --no-headers -o custom-columns=:metadata.name   | xargs -n1 kubectl delete elastic --all -n
kubectl delete -f https://download.elastic.co/downloads/eck/1.0.0-beta1/all-in-one.yaml
kubectl delete validatingwebhookconfigurations validating-webhook-configuration
kubectl delete  --all pv
kubectl delete -f ./kibana.yaml
