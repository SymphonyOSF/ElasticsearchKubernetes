# Elastic search cluster creation instructions

A Docker image is provided with all the dependencies for connecting to the EKS cluster and performing operations on it.
   
## Requirements

#### 1. Docker
https://docs.docker.com/docker-for-mac/install/

#### 2. Request Kuberentes account creation
The account used for creating the EKS cluster (used for running terraform) will have the cluster-admin role attached to it.

If any other accounts want to access the Kubernetes cluster,    execute the following steps from an existing user with the cluster-role attached to it (e.g. the user who applied the terraform scripts):



More info about this procedure can be found: https://aws.amazon.com/premiumsupport/knowledge-center/amazon-eks-cluster-access/
  

## Execution

#### 1. Run and SSH into the container by executing 
```bash
$ docker run -it luisplazas/elasticdeployment 
```

Configure kubectl connection to EKS.
```bash
$ cd ~
$ ./configure_connection.sh
```