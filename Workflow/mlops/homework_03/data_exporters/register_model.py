import mlflow
from mlflow.tracking import MlflowClient
import pandas as pd
import pickle

from sklearn.feature_extraction import DictVectorizer
from sklearn.linear_model import LinearRegression

if 'data_exporter' not in globals():
    from mage_ai.data_preparation.decorators import data_exporter

TRACKING_URI = "http://127.0.0.1:5000"
EXPERIMENT_NAME = 'LR-model'

mlflow.set_tracking_uri(TRACKING_URI)
mlflow.set_experiment(EXPERIMENT_NAME)
mlflow.sklearn.autolog()

@data_exporter
def export_data(data, *args, **kwargs):

    with mlflow.start_run():
        dv, lr = data
        print(dv)
        print(lr)
        with open("models/encoder.b", "wb") as f_out:
            pickle.dump(dv, f_out)
        
        mlflow.log_artifact("models/encoder.b", artifact_path="preprocessor")

        mlflow.sklearn.log_model(
            sk_model=lr,
            artifact_path="sklearn-model",
            registered_model_name="linear-reg-model",
        )