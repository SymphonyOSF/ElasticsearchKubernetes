#!/usr/bin/env bash
#Build base image
docker build . -f ./Dockerfile.deploy-base -t luisplazas/deploy-base
#docker push luisplazas/deploy-base

#Build eks deployment image
docker build . -f ./Dockerfile.eks-deploy -t luisplazas/eks-deploy
#docker push luisplazas/eks-deploy

#Build elastic deployment image
docker build . -f ./Dockerfile.elastic-deploy -t luisplazas/elastic-deploy
#docker push luisplazas/elastic-deploy
