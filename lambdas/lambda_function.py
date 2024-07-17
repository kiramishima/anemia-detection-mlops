import os
import json
import boto3
import base64
import mlflow
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

RUN_ID = os.getenv('RUN_ID')

logged_model = f's3://mlflow-anemia-models/1/{RUN_ID}/artifacts/model'
model = mlflow.pyfunc.load_model(logged_model)

TEST_RUN = os.getenv('TEST_RUN', 'False') == 'True'

def prepare_features(record):
    features = {}
    features['%Red Pixel'] = record['r']
    features['%Green pixel'] = record['g']
    features['%Blue pixel'] = record['b']
    features['Hb'] = record['hb']
    return features


def predict(features):
    pred = model.predict(features)
    return float(pred[0])

def lambda_handler(event, context):
    