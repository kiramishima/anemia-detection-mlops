FROM python:3.10-slim

ARG S3_URI=s3://mlflow-anemia-models/
ARG DB_URI=sqlite:///home/mlflow/mlflow.db

ENV S3_URI=${S3_URI}
ENV DB_URI=${DB_URI}

RUN pip install mlflow==2.12.1
# RUN pip install psycopg2-binary
COPY [ "Pipfile", "Pipfile.lock", "./" ]

RUN pip install pipenv

RUN pipenv install --system --deploy

EXPOSE 5000

CMD [ "/bin/sh", "-c", "mlflow server --backend-store-uri $DB_URI --host 0.0.0.0 --port 5000 --default-artifact-root $S3_URI"]