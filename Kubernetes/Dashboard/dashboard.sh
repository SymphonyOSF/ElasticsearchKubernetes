#!/usr/bin/env bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta4/aio/deploy/recommended.yaml
kubectl apply -f user.yaml
kubectl apply -f cluster_binding.yaml
