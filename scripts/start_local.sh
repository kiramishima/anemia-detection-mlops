#!/usr/bin/env bash

ls -l

PROJECT_NAME=mlops_anemia \
    MAGE_CODE_PATH=/home/src \
    docker compose up -d


# Buckets
aws --endpoint-url=http://localhost:4566 s3 s3://mlflow-anemia-models
aws --endpoint-url=http://localhost:4566 s3 mb s3://evidently-workspace