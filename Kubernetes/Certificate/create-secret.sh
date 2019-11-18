#!/usr/bin/env bash
kubectl create secret generic my-cert --from-file=tls.crt=cert.pem --from-file=tls.key=key.key --from-file=ca.crt=ca.pem