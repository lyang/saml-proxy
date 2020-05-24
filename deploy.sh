#!/bin/bash

set -o errexit
set -o nounset

REPO=$1
TAG=$2

docker build . -t $REPO:$TAG
docker push $REPO:$TAG
