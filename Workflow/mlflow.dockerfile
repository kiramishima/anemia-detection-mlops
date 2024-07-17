FROM python:3.10-slim

RUN pip install mlflow==2.12.1
# RUN pip install psycopg2-binary
COPY [ "Pipfile", "Pipfile.lock", "./" ]

RUN pip install pipenv

# RUN pipenv install --system --deploy

EXPOSE 5000

CMD [ \
    "mlflow", "server", \
    "--backend-store-uri", "sqlite:///home/mlflow/mlflow.db", \
    "--host", "0.0.0.0", \
    "--port", "5000" \
]