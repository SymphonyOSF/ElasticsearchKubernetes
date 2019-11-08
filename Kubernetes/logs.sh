#!/usr/bin/env bash
if [[ "$1" == "operator" ]]
then
    kubectl logs --namespace elastic-system  elastic-operator-0 -f
elif [[ "$1" == "scaler" ]]
then
    kubectl -n kube-system logs deployment.apps/cluster-autoscaler -f
else
    echo "----------------------------------------------"
    echo "Kubernetes log follower"
    echo "----------------------------------------------"
    echo "One argument is necessary"
    echo "logs.sh [argument]"
    echo "[argument] supported: operator,scaler"
    echo "E.g. ./logs.sh operator"
    exit 1
fi