# Tests

This folder contains tests for the EKS ES cluster deployment.

## Installation

Use the package manager [pip](https://pip.pypa.io/en/stable/) to install **requests**.

```bash
pip install requests
```

## Executing tests

Make sure a cluster is up and running and the terminal session is connected to the EKS cluster.

```bash
$ python test_elasticsearch.py -c ELASTICSEARCH_CLUSTER_NAME
```