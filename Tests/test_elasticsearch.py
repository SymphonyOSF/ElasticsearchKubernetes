# ================================================================================================
# Tests for Checking the Elasticsearch Layer
# ================================================================================================

import os
import json
import yaml
import logging
import argparse
import requests


def init(cluster_name):
    # Initialize logging module
    logging.basicConfig(level=logging.INFO, format='%(asctime)s - [%(levelname)s] - %(message)s', datefmt='%Y-%m-%d %H:%M:%S')
    logging.info("The cluster name is: " + cluster_name)

    # Record Elasticsearch and Kibana Endpoint
    ELB_ENDPOINT    = 'https://' + os.popen('kubectl get svc/' + cluster_name + '-es-http -o json | jq \'.status.loadBalancer.ingress[0].hostname\'').read().rstrip().strip('"') + ':9200'
    KIBANA_ENDPOINT = 'https://' + os.popen('kubectl get svc/kibana-' + cluster_name + '-kb-http -o json | jq \'.status.loadBalancer.ingress[0].hostname\'').read().rstrip().strip('"') + ':5601'

    # Record Elasticsearch HTTP Credential
    ES_PASSWORD     = os.popen('kubectl get secret \'' + cluster_name + '-es-elastic-user\'  -o=jsonpath=\'{.data.elastic}\' | base64 --decode').read()

    # List of Elasticsearch plugins
    ES_PLUGINS = ('repository-s3', 'discovery-ec2', 'analysis-icu')

    return (ELB_ENDPOINT, KIBANA_ENDPOINT, ES_PASSWORD, ES_PLUGINS)


# Test if Elasticsearch elb endpoint is working
def test_elasticsearch_endpoint(ELB_ENDPOINT, PASSWORD):
    logging.info('Testing if Elasticsearch Endpoint response status is 200...')

    response = requests.get(ELB_ENDPOINT, verify=False, auth=('elastic', PASSWORD))

    if response.status_code != 200:
        logging.error('Could not get HTTP response 200 from ' + ELB_ENDPOINT)
        return 1
    else:
        logging.info('Elasticsearch is up and running')
        return 0


# Test if Elasticsearch cluster status is green
def test_elasticsearch_status_green(ELB_ENDPOINT, PASSWORD):
    logging.info('Testing if Elasticsearch cluster is green...')

    response = requests.get(ELB_ENDPOINT + '/_cluster/health', verify=False, auth=('elastic', PASSWORD))
    json_response = json.loads(response.text)

    if json_response['status'] != 'green':
        logging.error('Could not get status green from ' + ELB_ENDPOINT)
        return 1
    else:
        logging.info('Elasticsearch Cluster is GREEN in health')
        return 0


# Test for the correct number of nodes (master + data nodes)
def test_elasticsearch_num_of_nodes(ES_NODES, PASSWORD, CLUSTER_NAME):
    logging.info('Testing if the correct number of elasticsearch nodes are up...')

    # Parse 'elasticsearch' resource for the true node count
    node_count_should_be = int(os.popen('kubectl get elasticsearch -o json | jq \'.items[0].spec.nodeSets[] | .count\' | jq -s \'add\' ').read().rstrip())

    response = requests.get(ELB_ENDPOINT + '/_nodes', verify=False, auth=('elastic', PASSWORD))
    node_count_is = json.loads(response.text)['_nodes']['total']

    if node_count_should_be != node_count_is:
        logging.error('Number of nodes should be ' + str(node_count_should_be) + ' but is ' + str(node_count_is))
        return 1
    else:
        logging.info('Correct number of nodes are up')
        return 0


# Test if the required plugins are installed
def test_elasticsearch_plugins(ELB_ENDPOINT, PASSWORD, ES_PLUGINS):
    logging.info('Testing if Elasticsearch Nodes have the installed plugins...')

    # List of Elasticsearch Node Names in the cluster
    NODES_INFO = json.loads(requests.get(ELB_ENDPOINT + '/_cat/nodes?format=json', verify=False, auth=('elastic', ES_PASSWORD)).text)
    ES_NODES   = [node_info['name'] for node_info in NODES_INFO]

    response = requests.get(ELB_ENDPOINT + '/_cat/plugins?format=json', verify=False, auth=('elastic', PASSWORD))
    json_response = json.loads(response.text)

    total_count_should_be = len(ES_NODES) * len(ES_PLUGINS)
    total_count_is = 0
    for item in json_response:
        if item['name'] in ES_NODES and item['component'] in ES_PLUGINS:
            total_count_is += 1

    if total_count_should_be != total_count_is:
        logging.error('One or more plugins are not installed on ES node(s)')
        return 1
    else:
        logging.info('The required plugins are installed on all ES node(s)')
        return 0


# Test if Kibana is working
def test_kibana_endpoint(KIBANA_ENDPOINT):
    logging.info('Testing if Kibana Endpoint response status is 200...')

    response = requests.get(KIBANA_ENDPOINT, verify=False, allow_redirects=True)

    print(response.status_code)

    if response.status_code != 200:
        logging.error('Could not get HTTP response 200 from ' + KIBANA_ENDPOINT)
        return 1
    else:
        logging.info('Kibana is up and running')
        return 0


if __name__ == '__main__':
    # Read CLI Arguments
    parser = argparse.ArgumentParser(description='Used for testing the elasticsearch layer of the EKS ES Cluster', usage='python test_elasticsearch.py -c cluster_name')
    parser.add_argument("-c", "--cluster-name", type=str, required=True, help="The name of the elasticsearch cluster.")
    args = parser.parse_args()

    cluster_name = args.cluster_name

    ELB_ENDPOINT, KIBANA_ENDPOINT, ES_PASSWORD, ES_PLUGINS = init(cluster_name)

    logging.info("Starting Elasticsearch tests...")

    # Test if ELB is up before running other tests
    if test_elasticsearch_endpoint(ELB_ENDPOINT, ES_PASSWORD) == 1:
        raise Exception('ELB Endpoint not up, ending tests...')

    total_errors = 0
    total_errors += test_elasticsearch_status_green(ELB_ENDPOINT, ES_PASSWORD)
    total_errors += test_elasticsearch_num_of_nodes(ELB_ENDPOINT, ES_PASSWORD, cluster_name)
    total_errors += test_elasticsearch_plugins(ELB_ENDPOINT, ES_PASSWORD, ES_PLUGINS)
    total_errors += test_kibana_endpoint(KIBANA_ENDPOINT)

    if total_errors > 0:
        raise Exception('One or more tests failed. Total errors: ' + total_errors)
    else:
        logging.info('All tests passed. This ES Cluster should be good to go!')