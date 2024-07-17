import mlflow
import os
import pickle
from mlflow.tracking import MlflowClient
from sklearn.metrics import root_mean_squared_error

if 'data_exporter' not in globals():
    from mage_ai.data_preparation.decorators import data_exporter


TRACKING_URI = "http://localhost:5000"
EXPERIMENT_NAME = 'LR-Anemia-model'

mlflow.set_tracking_uri(TRACKING_URI)
mlflow.set_experiment(EXPERIMENT_NAME)
mlflow.sklearn.autolog()


@data_exporter
def export_data(data, *args, **kwargs) -> str:
    X_train, X_test, Y_train, Y_test, le, model = data

    os.makedirs('models', exist_ok=True)
    artifact_uri = ''
    run_id = ''

    with mlflow.start_run() as run:
        # Encoder
        mlflow.set_tag("ML Engineer", "Paul Arizpe")
        with open("models/encoder.pkl", "wb") as f_out:
            pickle.dump(le, f_out)

        mlflow.log_artifact("models/encoder.pkl", artifact_path="preprocessor")
        # Train
        with open("models/x_train.pkl", "wb") as f_out:
            pickle.dump(X_train, f_out)

        mlflow.log_artifact("models/x_train.pkl", artifact_path="preprocessor")

        with open("models/y_train.pkl", "wb") as f_out:
            pickle.dump(Y_train, f_out)

        mlflow.log_artifact("models/y_train.pkl", artifact_path="preprocessor")

        # Test
        with open("models/x_test.pkl", "wb") as f_out:
            pickle.dump(X_test, f_out)

        mlflow.log_artifact("models/x_test.pkl", artifact_path="preprocessor")

        with open("models/y_test.pkl", "wb") as f_out:
            pickle.dump(Y_test, f_out)

        mlflow.log_artifact("models/y_test.pkl", artifact_path="preprocessor")

        # Log Model
        mlflow.sklearn.log_model(
            sk_model=model, 
            artifact_path="models",
            registered_model_name="log-reg-anemia-model",
        )
        artifact_uri = mlflow.get_artifact_uri()
        run_id = run.info.run_id
        print(f"default artifact URI: '{artifact_uri}'")
        print(f"RunID: '{run.info.run_id}'")
        # Predict
        y_pred = model.predict(X_test)
        rmse = root_mean_squared_error(Y_test, y_pred)
        mlflow.log_metric("rmse", rmse)
        # Model Score
        model_score = model.score(X_test, Y_test)
        mlflow.log_metric("score", model_score)
    
    # Register Model
    # client = MlflowClient(TRACKING_URI)
    logged_model = f"runs:/{run_id}/models"
    mlflow.register_model(logged_model, f"{EXPERIMENT_NAME}")
    return logged_model, artifact_uri, run_id


