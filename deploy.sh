#!/bin/bash

set -o errexit
set -o nounset

REPO=$1
TAG=$2
SOURCE=$3
BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
REVISION=`git rev-parse HEAD`

docker build . \
  --build-arg BUILD_DATE="$BUILD_DATE" \
  --build-arg SOURCE=$SOURCE \
  --build-arg REVISION=$REVISION \
  -t $REPO:$TAG

docker push $REPO:$TAG
