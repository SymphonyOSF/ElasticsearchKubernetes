# Tests

This folder contains tests for the EKS ES cluster deployment.

## Installation

Use the package manager [pip](https://pip.pypa.io/en/stable/) to install **requests**.

```bash
pip install requests
```

## Executing tests

Make sure a cluster is up and running (follow these steps [here](https://perzoinc.atlassian.net/wiki/spaces/SEARCH/pages/643039459/Terraform+EKS+cluster+creation) and [here](https://perzoinc.atlassian.net/wiki/spaces/SEARCH/pages/646057441/CREATE+new+Elastic+cluster)) and the terminal session is connected to the EKS cluster.

```bash
$ ./run_tests.sh ELASTICSEARCH_CLUSTER_NAME
```