FROM python:3.12.2-slim

# RUN pip install mlflow==2.12.1
# RUN pip install psycopg2-binary
COPY [ "Pipfile", "Pipfile.lock", "./" ]

RUN pip install pipenv

RUN pipenv install --system --deploy

EXPOSE 5000

CMD [ \
    "mlflow", "server", \
    "--backend-store-uri", "postgresql://postgres:password@magic-database:5432/mlops", \
    "--host", "0.0.0.0", \
    "--port", "5000" \
]