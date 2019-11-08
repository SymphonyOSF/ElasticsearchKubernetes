#!/usr/bin/env bash
PASSWORD=$(kubectl get secret symsearch-es-elastic-user  -o=jsonpath='{.data.elastic}' | base64 --decode)
echo "Password is: $PASSWORD"
kubectl port-forward service/symsearch-kb-http 5601
