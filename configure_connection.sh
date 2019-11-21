#!/usr/bin/env bash
{ # try

    #Configure aws cli
    echo "When prompted, enter json as default output format"
    aws configure &&

    #Configure Kubectl connection
    read -r -p "Enter EKS cluster name: " input
    aws eks update-kubeconfig --name ${input} &&
    echo "Successfully configured kubectl"
    exit 0;
} || { # catch
    echo "An error was generated, please check stdout for mor details."
    exit 1 ;
}
