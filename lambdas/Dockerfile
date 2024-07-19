FROM amazon/aws-lambda-python:3.12

RUN pip install -U pip
RUN pip install pipenv

COPY [ "../lambdas/Pipfile", "../lambdas/Pipfile.lock", "./" ]

RUN pipenv install --system --deploy

COPY "../lambdas/__init__.py" ${LAMBDA_TASK_ROOT}
COPY "../lambdas/model.py" ${LAMBDA_TASK_ROOT}
COPY "../lambdas/lambda_function.py" ${LAMBDA_TASK_ROOT}

CMD [ "lambda_function.handler" ]