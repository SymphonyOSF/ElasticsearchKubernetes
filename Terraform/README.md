# EKS Cluster deployment instructions

1. Remote S3 backend and DynamoDB lock creation 

Go into the S3RemoteBackend directory and run:
```bash
$ terraform init
$ terraform apply 
```


**Alternative:** If a different S3 bucket and/or DynamoDB will be used, go to the main.tf file under the ./Terraform directory and change the **bucket** and **dynamodb_table** fields as necessary.  

2.  Eks infrastructure creation

Run from the ./Terraform directory:
```bash
$ terraform init
$ terraform apply 
```


## Resources created by this commands

The execution of the terraform scripts will create the following:

### Network
1. VPC in the desired region.
2. N subnets in the created VPC, each on a different availability zone.
3. Internet gateway for the VPC.
4. Route table for the VPC.


 