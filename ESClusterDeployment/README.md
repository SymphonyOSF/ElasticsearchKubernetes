# Elastic search cluster creation instructions

A Docker image is provided with all the dependencies and configurations needed to connect to the EKS cluster and start deploying/managing Elasticsearch clusters.
   
## Requirements

#### 1. Docker
https://docs.docker.com/docker-for-mac/install/

#### 2. Request Kuberentes access
The account used for creating the EKS cluster (used for running terraform) will have the cluster-admin role attached to it.

If any other accounts want to access the Kubernetes cluster, the user who created the cluster is required to perform the following steps:


1. On the AWS console, go into IAM (click on Services, search for *IAM*). 

2. Go to the Groups tab on the left.

3. Search for the group named **${CLUSTER_NAME}_master_users**

4. Add to the group the user(s) you want to give access to the cluster.

More info about this procedure can be found: https://aws.amazon.com/premiumsupport/knowledge-center/amazon-eks-cluster-access/

## Execution

Once you have satisfied all the previously defined requirements, execute the following to create a new Elastic cluster. 

#### 1. Run and SSH into the container with all the dependencies by executing 
```bash
$ docker run -it luisplazas/elastic-deploy 
```
(Optional) You can see the contents of this image and build it locally with it's [Dockerfile](https://github.com/SymphonyOSF/ElasticsearchKubernetes/blob/master/Dockerfile.deploy)

#### 2. Configure kubectl connection to EKS.
```bash
$ cd ~
$ ./configure_connection.sh
```
You will have to input your AWS credentials, for more info on how to get/create them see: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey

Also, you will need to input the 2 following information about the EKS cluster:
* EKS cluster name: Name given to the cluster.
* Cluster auth role **ARN**: ARN of the role created for all the users of this cluster. The cluster creator can give you this information, or you can look it up by searching on the IAM page of the AWS console for a role named **${CLUSTER_NAME}_access_role**

**Important:** Keep in mind that the ARN is in the following format: arn:aws:iam::1891111100000:role/role_name 

#### 3. Create the Elasticsearch
```bash
$ cd ESClusterDeployment
$ ./create-es-cluster.sh
```
You will input the amount of data and master nodes, together with the amount of disk **each** data node will have.

The command execution will output the following:
1. Cluster name

2. Password for the **elastic** user, which is an auto-generated user with admin access. 

