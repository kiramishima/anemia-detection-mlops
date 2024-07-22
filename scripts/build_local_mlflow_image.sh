#!/usr/bin/env bash

LOCAL_TAG=`date +"%Y-%m-%d-%H-%M"`
export LOCAL_IMAGE_NAME="ml-anemia-tracking:${LOCAL_TAG}"
echo "Building a new mlflow image with tag ${LOCAL_IMAGE_NAME}"
ls -l
docker build -t ${LOCAL_IMAGE_NAME} -f ./Workflow/mlflow.Dockerfile .

export S3_URI="s3://mlflow-anemia-models/"
export DB_URI="sqlite:///home/mlflow/mlflow.db"
