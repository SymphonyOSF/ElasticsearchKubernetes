#!/bin/bash
AMOUNT_OF_INDICES=$1
NUM_DOCS_IN_MILLIONS=$3
PASSWORD=$(kubectl get secret symsearch-es-elastic-user  -o=jsonpath='{.data.elastic}' | base64 --decode)

if [ "$#" -le 2 ]; then
    echo "Number of arguments should be 3"
    echo "Usage: create_schemas.sh [number of indices] ELASTIC_URL:ELASTIC_PORT [num_documents_in_millions per index]"
    echo "E.g. ./create_schemas.sh 10 localhost:9200 10"
    echo "This command will:"
    echo "   1. Delete all socialmessage indices"
    echo "   2. Create 10 new indices with the schema found on the current directory (./elastic-schema.json)"
    echo "   3. Restore one snapshot from the s3 repository, the size of the snapshot to be restored is controlled by the second number parameter."
    echo "   4. Wait for the restore to finish"
    echo "   5. Re-index the restored index snapshot into the 10 indices created on step 3."
    echo "   6. Wait for the re-indexing tasks to finish (this is optional, you may quit the command at this point and just wait until all indices have the desired # of docs)"
    exit 1
fi

ELB_URL="$2"

function recover_indices (){
    recover_index $2;
    for ((i=0; i < $1; i++));
    do
        echo "Task for index socialmessage$i:"
        curl -u "elastic:$PASSWORD" -k -X POST "$ELB_URL/_reindex?wait_for_completion=false&pretty" -H 'Content-Type: application/json' -d'
        {
          "source": {
            "index": "socialmessage"
          },
          "dest": {
            "index": "socialmessage'$i'"
          }
        }
        '
    done
    wait_for_reindex
    return 12
}

function recover_index(){
    echo "Restoring snapshot ..."
    curl -u "elastic:$PASSWORD" -k -X POST "$ELB_URL/_snapshot/s3_repository/${NUM_DOCS_IN_MILLIONS}m_sm_snapshot/_restore?wait_for_completion=true" -H 'Content-Type: application/json' -d '
    {
      "indices": "socialmessage",
      "include_global_state": false,
      "rename_pattern": "socialmessage",
      "rename_replacement": "socialmessage",
      "index_settings": {
        "index.number_of_replicas": 0
      }
    }'
    sleep 1;
    echo "Snapshot call finished"
    echo "----------------------------";
}

function wait_for_reindex() {
    echo "Waiting for re-index operations to complete...";
    curl -u "elastic:$PASSWORD" -k -m 1000000 -s -XGET "http://$ELB_URL/_tasks?actions=*reindex&wait_for_completion=true&timeout=1000000s"
    echo "Re-index operations completed";
}

function delete_indices(){
    delete_index "socialmessage"
    for ((i=0; i<$1; i++));
    do
       delete_index "socialmessage$i"
    done
}

function create_indices(){
    for ((i=0; i<$1; i++));
    do
       create_index "socialmessage$i"
    done
}

function create_index() {
    echo "*****************************************************************************"
    echo Creating "$1" index
    echo "*****************************************************************************"
    cat elastic-schema.json | curl -u "elastic:$PASSWORD" -k --retry 10 --retry-connrefused -X PUT "${ELB_URL}/$1" -H 'Content-Type: application/json' -d '@-'
}

function delete_index() {
    echo "*****************************************************************************"
    echo Deleting "$1" index
    echo "*****************************************************************************"
    curl -u "elastic:$PASSWORD" -k --retry 10 --retry-connrefused -X DELETE "${ELB_URL}/$1"
}

function register_s3_repo(){
    echo "Registering S3 repository..."
    curl -u "elastic:$PASSWORD" -k --retry 10 --retry-connrefused -X PUT "${ELB_URL}/_snapshot/s3_repository" -H 'Content-Type: application/json' -d '
    {
      "type": "s3",
      "settings": {
        "bucket": "sym-elastic-snapshot"
      }
    }'
    echo "Finished registering snapshot repo..."
 }

register_s3_repo;
delete_indices ${AMOUNT_OF_INDICES};
create_indices ${AMOUNT_OF_INDICES};
recover_indices ${AMOUNT_OF_INDICES} $2;
