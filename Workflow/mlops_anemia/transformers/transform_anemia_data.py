from sklearn.preprocessing import LabelEncoder
import polars as pl
import numpy as np

if 'transformer' not in globals():
    from mage_ai.data_preparation.decorators import transformer
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@transformer
def transform(data, *args, **kwargs) -> tuple:
    # Select only RGB Pixel, Hb & Anaemic
    df = data.select(
        pl.col('%Red Pixel'),
        pl.col('%Green pixel'),
        pl.col('%Blue pixel'),
        pl.col('Hb'),
        pl.col('Anaemic')
    )
    # Encoder
    le = LabelEncoder()

    # Select Anaemic column
    anaemic = df.select(pl.col('Anaemic'))
    # Apply the encoder
    Y = le.fit_transform(anaemic)
    # Update the dataframe
    df = df.with_columns(
        Anaemic=pl.lit(Y)
    )

    return le, df


@test
def test_output(le_output, df_output, *args) -> None:
    assert df_output is not None, 'The output is undefined'
    assert df_output.columns != 0, "The Dataframe doesn´t contain columns"
    assert isinstance(le_output, LabelEncoder), "The Dataframe contain more than 5 columns"
