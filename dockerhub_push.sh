#!/bin/bash

# Any subsequent command which fails will cause the shell script to exit immediately
set -e

DOCKER_REPOSITORY=$1

ALTERNATIVE_TAG=latest
if [ ! -z "$CIRCLE_TAG" ]; then
  UNIQUEID=release-$CIRCLE_TAG
fi

if [ ! -z "$CIRCLE_BRANCH" ]; then
  UNIQUEID=$CIRCLE_BRANCH-$CIRCLE_SHA1
fi

    
# Build the docker image
echo Build the docker image $DOCKER_REPOSITORY:$UNIQUEID
docker build -t $DOCKER_REPOSITORY:$UNIQUEID .

# Deploy image to Docker Hub
echo Pushing docker image $DOCKER_REPOSITORY:$UNIQUEID
# Login to docker hub
docker login -u $DOCKER_USER -p $DOCKER_PASS
docker push $DOCKER_REPOSITORY:$UNIQUEID

echo Tag the docker image as $DOCKER_REPOSITORY:$ALTERNATIVE_TAG
docker tag $DOCKER_REPOSITORY:$UNIQUEID $DOCKER_REPOSITORY:$ALTERNATIVE_TAG
echo Pushing docker image as $DOCKER_REPOSITORY:$ALTERNATIVE_TAG
docker push $DOCKER_REPOSITORY:$ALTERNATIVE_TAG