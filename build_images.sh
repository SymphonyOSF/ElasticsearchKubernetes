#!/usr/bin/env bash
PUSH_IMAGE=false
if [[ $1 == "-push" ]]; then
  PUSH_IMAGE=true
fi

#Build base image
docker build . -f ./Dockerfile.deploy-base -t luisplazas/deploy-base
if [[ $PUSH_IMAGE == true ]]; then
 docker push luisplazas/deploy-base
fi

#Build eks deployment image
docker build . -f ./Dockerfile.eks-deploy -t luisplazas/eks-deploy
if [[ $PUSH_IMAGE == true ]]; then
  docker push luisplazas/eks-deploy
fi

#Build elastic deployment image
docker build . -f ./Dockerfile.elastic-deploy -t luisplazas/elastic-deploy
if [[ $PUSH_IMAGE == true ]]; then
  docker push luisplazas/elastic-deploy
fi

#Build elasticsearch
docker build . -f ./Dockerfile.elastic -t elastic:7.4.2
if [[ $PUSH_IMAGE == true ]]; then
  docker push luisplazas/elastic:7.4.2
fi
