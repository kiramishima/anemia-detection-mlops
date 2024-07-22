FROM python:3.12-slim

ARG S3_WS=s3://evidently-workspace
ENV S3_WS=${WS}

# Evidently
RUN pip install evidently

EXPOSE 8000

CMD [ \
    "evidently", "ui", \
    "--workspace", "${S3_WS}" \
]