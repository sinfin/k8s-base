#!/bin/bash

stage=$1

BASE_SHA=$(sha1sum Dockerfile.base | cut -d' ' -f1)
PACKAGES_SHA=$(sha1sum Dockerfile.base Dockerfile.packages Gemfile.lock | sha1sum | cut -d' ' -f1)

set -x

case $stage in
  base)
    docker build --pull -t ${CI_REGISTRY_IMAGE}/base:$BASE_SHA -f Dockerfile.base .
    docker push ${CI_REGISTRY_IMAGE}/base:$BASE_SHA
    if [ "$CI_COMMIT_REF_SLUG" = "master" ]; then
      docker tag ${CI_REGISTRY_IMAGE}/base:$BASE_SHA ${CI_REGISTRY_IMAGE}/base:latest
      docker push ${CI_REGISTRY_IMAGE}/base:latest
    fi
    ;;
  packages)
    docker build --pull --build-arg BASE=$BASE_SHA --build-arg CI_REGISTRY_IMAGE=$CI_REGISTRY_IMAGE -t ${CI_REGISTRY_IMAGE}/packages:$PACKAGES_SHA -f Dockerfile.packages .
    docker push ${CI_REGISTRY_IMAGE}/packages:$PACKAGES_SHA
    ;;
  app)
    docker build --pull --build-arg BASE=$PACKAGES_SHA --build-arg CI_REGISTRY_IMAGE=$CI_REGISTRY_IMAGE -t ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHA} -f Dockerfile .
    docker push ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHA}
    ;;
  *) 
    echo "Unknown stage"
    exit 1
esac

