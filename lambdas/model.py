import os
import json
import base64

import boto3
import mlflow


def get_model_location(run_id):
    model_location = os.getenv('MODEL_LOCATION')

    if model_location is not None:
        return model_location

    model_bucket = os.getenv('MODEL_BUCKET', 'mlflow-anemia-models')
    experiment_id = os.getenv('MLFLOW_EXPERIMENT_ID', '1')

    model_location = f's3://{model_bucket}/{experiment_id}/{run_id}/artifacts/models'
    return model_location

def load_model(run_id):
    model_path = get_model_location(run_id)
    model = mlflow.pyfunc.load_model(model_path)
    return model

class ModelService:
    def __init__(self, model, model_version=None):
        self.model = model
        self.model_version = model_version

    def prepare_features(self, record):
        features = {}
        features['%Red Pixel'] = record['r']
        features['%Green pixel'] = record['g']
        features['%Blue pixel'] = record['b']
        features['Hb'] = record['hb']
        return features


    def predict(self, features):
        pred = self.model.predict(features)
        return float(pred[0])

    def lambda_handler(self, event):
        print(event)

        features = self.prepare_features(event)
        prediction = self.predict(features)

        return {'predictions': prediction}

def init(run_id: str, test_run: bool):
    model = load_model(run_id)

    model_service = ModelService(model=model, model_version=run_id)

    return model_service