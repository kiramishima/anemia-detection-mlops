FROM python:3.12-slim

RUN pip install mlflow==2.12.1

EXPOSE 5000

CMD [ \
    "mlflow", "server", \
    "--backend-store-uri", "postgresql://postgres:password@magic-database:5432/mlops", \
    "--host", "0.0.0.0", \
    "--port", "5000" \
]