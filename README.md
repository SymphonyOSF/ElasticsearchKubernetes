# Elasticsearch deployment on EKS K8s

Complete project for deploying and managing Elasticsearch clusters on Kubernetes by making use of EKS(AWS).

This deployment automates the following capabilities:
* Auto-scale down: Data transfer to other nodes before removing the node. Can be scaled down based on a node being consistently unneeded for a set amount of time. (or manually if wanted).
* Auto-scale up: Automatic configuration and addition of nodes to the existing ES cluster. Scales up based on pods that fail to be scheduled due to insufficient resources (or manually if wanted).
* Cross-AZ(availability zone) deployment: Can deploy nodes in 2+ availability zones for improved resilience.
* Node orchestration: Orchestrate nodes across multiple AZs, maintain an even number of node across all AZs.    
* Self healing: If an elastic node comes down or becomes unresponsive, it will automatically be put out of service and replaced by kubernetes. It will also take the EBS volume and attach it to the new node.   
* Load balancing: Balance http requests between all data nodes. Can be changed to distribute load to any group node (E.g. forward all requests to dedicated coordinating nodes -also known as http/client nodes-).
* Periodic snapshots
* Periodic merges
* Secret and configuration management.

# Project structure

### Docker image
A custom image is built on top of the official elasticsearch image on ./ElasticImage directory

### Infrastructure code
All the infrastructure required for deploying the cluster is managed using terraform on the ./Terraform directory.

### Kubernetes files
All the Kubernetes resources are defined on the ./Kubernetes directory.
