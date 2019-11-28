#!/usr/bin/env bash

function delete_cluster() {
    echo "Starting clean up..."
#    Delete all elasticsearch operator resources
    kubectl get namespaces --no-headers -o custom-columns=:metadata.name | xargs -n1 kubectl delete elastic --all -n
    kubectl delete -f ./all-in-one.yaml
    kubectl delete validatingwebhookconfigurations validating-webhook-configuration

#    Delete Kubernetes Dashboard
    kubectl delete -f ./Dashboard/cluster_binding.yaml
    kubectl delete -f ./Dashboard/user.yaml
    kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta4/aio/deploy/recommended.yaml

#    Delete autoscaler
    kubectl delete -f ./cluster-autoscaler-autodiscover.yaml

#    Delete k8s config_map
    kubectl delete -f ./config_map_aws_auth.yml

#    Delete all Persistent Volumes
    kubectl delete  --all pv

    #Bring down DNS mapping service
    kubectl delete -f ./DNS/external_dns.yaml
}

if [[ $0 != "-y" ]]; then
    echo "This command will delete ALL Elastic clusters."
    read -r -p "Are You Sure? [Y/n] " input

    case $input in
        [yY][eE][sS]|[yY])
            delete_cluster
        ;;
        [nN][oO]|[nN])
            echo "Cancelling execution."
        ;;
        *)
     echo "Invalid input..."
     exit 1
     ;;
    esac
else
    delete_cluster
fi
