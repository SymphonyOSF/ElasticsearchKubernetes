#!/usr/bin/env bash
kubectl delete -f cluster_binding.yaml
kubectl delete -f user.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta4/aio/deploy/recommended.yaml
