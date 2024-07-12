import polars as pl

if 'data_loader' not in globals():
    from mage_ai.data_preparation.decorators import data_loader
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@data_loader
def load_data(*args, **kwargs):
    URL = 'https://raw.githubusercontent.com/kiramishima/anemia-detection-mlops/master/DATA/anemia_dataset.csv'
    df = pl.read_csv(URL, truncate_ragged_lines=True)

    return df


@test
def test_output(output, *args) -> None:
    assert output is not None, 'The output is undefined'
    assert len(output.columns) != 0, "Error loading data or the csv doesn't contain data"
