import polars as pl
import os
import datetime
import pickle
import mlflow
from mlflow.tracking import MlflowClient
#Evidently
from evidently import ColumnMapping
from evidently.report import Report
from evidently.metrics import ColumnDriftMetric, DatasetDriftMetric, DatasetMissingValuesMetric, ColumnQuantileMetric, ColumnCorrelationsMetric
from evidently.metric_preset import DataDriftPreset, DataQualityPreset
from evidently.ui.workspace import RemoteWorkspace, Workspace
from evidently.ui.dashboards import DashboardPanelCounter, DashboardPanelPlot, CounterAgg, PanelValue, PlotType, ReportFilter
from evidently.renderers.html_widgets import WidgetSize

if 'data_exporter' not in globals():
    from mage_ai.data_preparation.decorators import data_exporter


WS_NAME = os.environ.get('EVIDENTLY_HOST', 'http://localhost:8000')
TRACKING_URI = "http://localhost:5000"
EXPERIMENT_NAME = 'LR-Anemia-model'

@data_exporter
def export_data(data, *args, **kwargs):
    logged_model, artifact_uri, run_id = data
    print(logged_model, artifact_uri, run_id)
    target = pl.col("Anaemic")
    num_features = (
        '%Red Pixel',
        '%Green pixel',
        '%Blue pixel',
        'Hb'
    )

    # Load Model from MLFlow
    loaded_model = mlflow.pyfunc.load_model(logged_model)
    # Load Data
    client = MlflowClient()
    tmp_path = client.download_artifacts(run_id, "preprocessor/x_train.pkl")
    with open(tmp_path, 'rb') as f:
        X_train = pickle.load(f)
    tmp_path = client.download_artifacts(run_id, "preprocessor/y_train.pkl")
    with open(tmp_path, 'rb') as f:
        Y_train = pickle.load(f)
    # print(X_train, Y_train)

    tmp_path = client.download_artifacts(run_id, "preprocessor/x_test.pkl")
    with open(tmp_path, 'rb') as f:
        X_test = pickle.load(f)
    tmp_path = client.download_artifacts(run_id, "preprocessor/y_test.pkl")
    with open(tmp_path, 'rb') as f:
        Y_test = pickle.load(f)
    
    # print(X_test, Y_test)
    # Evaluate
    pred = loaded_model.predict(X_train)
    df_train = X_train.with_columns(
        Anaemic=pl.lit(Y_train.get_column('Anaemic').to_list()),
        Pred_Anaemic=pl.lit(pred)
    )
    pred = loaded_model.predict(X_test)
    df_test = X_test.with_columns(
        Anaemic=pl.lit(Y_test.get_column('Anaemic').to_list()),
        Pred_Anaemic=pl.lit(pred)
    )
    # print(df_train)
    # Evidently Mapping
    column_mapping = ColumnMapping(
        target='Anaemic',
        prediction='Pred_Anaemic',
        numerical_features=num_features
    )
    
    # Evidently Report
    report = Report(
        metrics=[
            DatasetDriftMetric(),
            ColumnDriftMetric(column_name='%Red Pixel'),
            ColumnDriftMetric(column_name='%Green pixel'),
            ColumnDriftMetric(column_name='%Blue pixel'),
            ColumnDriftMetric(column_name='Hb'),
            ColumnDriftMetric(column_name='Pred_Anaemic'),
            DatasetMissingValuesMetric()
        ],
        timestamp=datetime.datetime.now()
    )
    
    # create a workspace
    ws = RemoteWorkspace("http://localhost:8000")
    print()
    # print(df_train.to_pandas())

    # Reporting
    project = None
    if ws.search_project("Anemia Data Quality Project") is None:
        project = ws.create_project("Anemia Data Quality Project")
        project.description = "Anemia data monitoring"
        project.save()
    else:
        project = ws.search_project("Anemia Data Quality Project")[0]
    
    report.run(reference_data=df_train.to_pandas(),
                    current_data=df_test.to_pandas(),
                    column_mapping=column_mapping)

    ws.add_report(project.id, report)

    # configure the dashboard
    project.dashboard.add_panel(
        DashboardPanelCounter(
            filter=ReportFilter(metadata_values={}, tag_values=[]),
            agg=CounterAgg.NONE,
            title="Anemia data dashboard"
        )
    )

    project.dashboard.add_panel(
        DashboardPanelPlot(
            filter=ReportFilter(metadata_values={}, tag_values=[]),
            title="Inference Count",
            values=[
                PanelValue(
                    metric_id="DatasetSummaryMetric",
                    field_path="current.number_of_rows",
                    legend="count"
                ),
            ],
            plot_type=PlotType.BAR,
            size=WidgetSize.HALF,
        ),
    )

    project.dashboard.add_panel(
        DashboardPanelPlot(
            filter=ReportFilter(metadata_values={}, tag_values=[]),
            title="Number of Missing Values",
            values=[
                PanelValue(
                    metric_id="DatasetSummaryMetric",
                    field_path="current.number_of_missing_values",
                    legend="count"
                ),
            ],
            plot_type=PlotType.LINE,
            size=WidgetSize.HALF,
        ),
    )

    project.save()