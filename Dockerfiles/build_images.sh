#!/usr/bin/env bash
PUSH_IMAGE=false
if [[ $1 == "-push" ]]; then
  PUSH_IMAGE=true
fi

docker build ../ -f ./Dockerfile.deployment -t luisplazas/deployment:latest
if [[ ${PUSH_IMAGE} == true ]]; then
 docker push luisplazas/deployment
fi

#Build elasticsearch
docker build ../ -f ./Dockerfile.elastic -t elastic:7.4.2
if [[ ${PUSH_IMAGE} == true ]]; then
  docker push luisplazas/elastic:7.4.2
fi
