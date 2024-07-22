#!/usr/bin/env bash

LOCAL_TAG=`date +"%Y-%m-%d-%H-%M"`
export LOCAL_IMAGE_NAME="anemia-model-prediction:${LOCAL_TAG}"
echo "Building a new image with tag ${LOCAL_IMAGE_NAME}"
ls -l
docker build -t ${LOCAL_IMAGE_NAME} -f ./lambdas/Dockerfile .

export S3_ENDPOINT_URL="http://localhost:4566"
export MLFLOW_S3_ENDPOINT_URL="http://localhost:4566"
export RUN_ID="0a41af9fc964432fb763bcd462af5fad"