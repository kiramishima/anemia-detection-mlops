from pathlib import Path

import json
import warnings
from lambdas.model import ModelService

warnings.filterwarnings('ignore')

def read_data(file: str):
    test_directory = Path(__file__).parent

    with open(test_directory / file, 'rt', encoding='utf-8') as f_in:
        return json.load(f_in)

class ModelMock:
    def __init__(self, value):
        self.value = value

    def predict(self, X):
        n = len(X)
        return [self.value] * n

def test_prepare_features():
    model_service = ModelService(None)

    data = read_data('data.json')
    actual_features = model_service.prepare_features(data[0])
    expected_fetures = {
        "%Red Pixel": 43.2555,
        "%Green pixel": 30.8421,
        "%Blue pixel": 25.9025,
        "Hb": 6.3
    }

    actual_features2 = model_service.prepare_features(data[1])
    expected_fetures2 = {
        "%Red Pixel": 45.6033,
        "%Green pixel": 28.19,
        "%Blue pixel": 26.2067,
        "Hb": 13.5
    }

    assert actual_features == expected_fetures
    assert actual_features2 == expected_fetures2

def test_predict_person_with_anemia():
    model_mock = ModelMock(1.0)
    model_service = ModelService(model_mock)

    features = {
        "%Red Pixel": 43.2555,
        "%Green pixel": 30.8421,
        "%Blue pixel": 25.9025,
        "Hb": 6.3
    }

    actual_prediction = model_service.predict(features)
    print(actual_prediction)
    expected_prediction = 1.0

    assert actual_prediction == expected_prediction

def test_predict_person_without_anemia():
    model_mock = ModelMock(0.0)
    model_service = ModelService(model_mock)

    features = {
        "%Red Pixel": 45.6033,
        "%Green pixel": 28.19,
        "%Blue pixel": 26.2067,
        "Hb": 13.5
    }

    actual_prediction = model_service.predict(features)
    print(actual_prediction)
    expected_prediction = 0.0

    assert actual_prediction == expected_prediction

def test_lambda_handler():
    model_mock = ModelMock(1.0)
    model_version = 'Test123'
    model_service = ModelService(model_mock, model_version)

    data = read_data('data.json')
    actual_predictions = model_service.lambda_handler(data[0])
    expected_predictions = {
        'predictions': 1.0
    }

    assert actual_predictions == expected_predictions