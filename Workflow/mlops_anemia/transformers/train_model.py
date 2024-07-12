import polars as pl
import numpy as np
from sklearn.preprocessing import LabelEncoder
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import root_mean_squared_error
import os
import pickle
import mlflow

if 'transformer' not in globals():
    from mage_ai.data_preparation.decorators import transformer
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test

# MLFlow
TRACKING_URI = os.environ.get("TRACKING_URI", "http://127.0.0.1:5000")
EXPERIMENT_NAME = os.environ.get("EXPERIMENT_NAME", "LR-Anemia-Model")
mlflow.set_experiment(EXPERIMENT_NAME)
mlflow.set_tracking_uri(TRACKING_URI)
mlflow.sklearn.autolog()

@transformer
def transform(data, *args, **kwargs):
    # Set MLFlow Autolog
    

    le, df = data

    # Target
    X = df.select(
        pl.col('%Red Pixel'),
        pl.col('%Green pixel'),
        pl.col('%Blue pixel'),
        pl.col('Hb')
    )
    print(X.shape)
    Y = df.select(
        pl.col('Anaemic')
    )
    print(Y.shape)
    

    # Model
    
    with mlflow.start_run():
        mlflow.set_tag("ML Engineer", "Paul Arizpe")
        # Train & Test
        X_train, X_test, Y_train, Y_test = train_test_split(X,Y, test_size = 0.20, random_state=42)
        # Model
        model = LogisticRegression()
        model.fit(X_train, Y_train)

        # Log Model
        mlflow.sklearn.log_model(
            sk_model=model, 
            artifact_path="models",
            registered_model_name="log-reg-anemia-model",
        )
        print(f"default artifact URI: '{mlflow.get_artifact_uri()}'")
        # Predict
        y_pred = model.predict(X_test)
        rmse = root_mean_squared_error(Y_test, y_pred)
        mlflow.log_metric("rmse", rmse)
        # Model Score
        model_score = model.score(X_test, Y_test)
        mlflow.log_metric("score", model_score)

    return data


@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output is not None, 'The output is undefined'
