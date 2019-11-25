# Elastic search cluster creation instructions

A Docker image is provided with all the dependencies and configurations needed to connect to the EKS cluster and start deploying/managing Elasticsearch clusters.
   
## Requirements

#### 1. Docker
https://docs.docker.com/docker-for-mac/install/

#### 2. Request Kuberentes account creation
The account used for creating the EKS cluster (used for running terraform) will have the cluster-admin role attached to it.

If any other accounts want to access the Kubernetes cluster,    execute the following steps from an existing user with the cluster-role attached to it (e.g. the user who applied the terraform scripts):

1. Get the output from the terraform execution [defined in this file.](https://github.com/SymphonyOSF/ElasticsearchKubernetes/blob/master/Terraform/output.tf) 

2. 

More info about this procedure can be found: https://aws.amazon.com/premiumsupport/knowledge-center/amazon-eks-cluster-access/
  
Info about aws-auth config map: https://itnext.io/how-does-client-authentication-work-on-amazon-eks-c4f2b90d943b

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