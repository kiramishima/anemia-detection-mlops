
#!/usr/bin/env bash

ls -l

pip install -U pip & pip install pipenv
pipenv install --system --deploy

env MLFLOW_S3_ENDPOINT_URL=http://localhost:4566 mage start mlops_anemia

env FSSPEC_S3_ENDPOINT_URL=http://localhost:4566 evidently ui --workspace s3://evidently-workspace

env MLFLOW_S3_ENDPOINT_URL=http://localhost:4566 mlflow server --backend-store-uri sqlite:///mlflow/mlflow.db --host 0.0.0.0 --port 5000 --default-artifact-root s3://mlflow-anemia-models/