#!/usr/bin/env bash

LOCAL_TAG=`date +"%Y-%m-%d-%H-%M"`
export LOCAL_IMAGE_NAME="ml-anemia-monitoring:${LOCAL_TAG}"
echo "Building a new evidently image with tag ${LOCAL_IMAGE_NAME}"
ls -l
docker build -t ${LOCAL_IMAGE_NAME} -f ./Workflow/evidently.Dockerfile .

export S3_WS=s3://evidently-workspace
export EVIDENTLY_IMAGE_NAME=${LOCAL_IMAGE_NAME}