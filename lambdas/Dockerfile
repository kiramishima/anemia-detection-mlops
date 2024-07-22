FROM amazon/aws-lambda-python:3.12

RUN pip install -U pip
RUN pip install pipenv

COPY [ "Pipfile", "Pipfile.lock", "./" ]

RUN pipenv install --system --deploy

COPY "__init__.py" ${LAMBDA_TASK_ROOT}
COPY "model.py" ${LAMBDA_TASK_ROOT}
COPY "lambda_function.py" ${LAMBDA_TASK_ROOT}

CMD [ "lambda_function.handler" ]