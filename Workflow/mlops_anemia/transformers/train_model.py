import polars as pl
import numpy as np
from sklearn.preprocessing import LabelEncoder
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import root_mean_squared_error
import os
import pickle
# import mlflow

if 'transformer' not in globals():
    from mage_ai.data_preparation.decorators import transformer
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test

# MLFlow


@transformer
def transform(data, *args, **kwargs):
    le, df = data
    # print(le)
    # print(df)

    # Target
    X = df.select(
        pl.col('%Red Pixel'),
        pl.col('%Green pixel'),
        pl.col('%Blue pixel'),
        pl.col('Hb')
    )
    Y = df.select(
        pl.col('Anaemic')
    )
    

    # Model
    # Train & Test
    X_train, X_test, Y_train, Y_test = train_test_split(X,Y, test_size = 0.20, random_state=42)
    # Model
    model = LogisticRegression()
    model.fit(X_train, Y_train)
    # Predict
    y_pred = model.predict(X_test)
    rmse = root_mean_squared_error(Y_test, y_pred)
    # print(f'RMSE: {rmse}')
    #    mlflow.log_metric("rmse", rmse)
    # Model Score
    model_score = model.score(X_test, Y_test)
    # print(f'Score: {model_score}')
    #    mlflow.log_metric("score", model_score)

    return X_train, X_test, Y_train, Y_test, le, model


@test
def test_output(X_train, X_test, Y_train, Y_test, le, model, *args) -> None:
    assert isinstance(model, LogisticRegression), "models isn´t instance of LogisticRegression"
