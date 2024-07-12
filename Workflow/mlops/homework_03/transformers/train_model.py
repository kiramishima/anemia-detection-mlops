import pandas as pd
from sklearn.feature_extraction import DictVectorizer
from scipy.sparse import csr_matrix
from sklearn.linear_model import LinearRegression

if 'transformer' not in globals():
    from mage_ai.data_preparation.decorators import transformer
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@transformer
def transform(df1, *args, **kwargs):
    categorical = ['PULocationID', 'DOLocationID']
    target = ['duration']
    # OHE
    trains_dicts = df1[categorical].astype(str).to_dict(orient='records')
    dv = DictVectorizer()
    X_train = dv.fit_transform(trains_dicts)
    X_train = csr_matrix(X_train)
    Y_train = df1[target]
    # Model
    lr = LinearRegression()
    lr.fit(X_train, Y_train)

    y_pred = lr.predict(X_train)
    print(f"Model intercept is {lr.intercept_}")

    return dv, lr


@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output is not None, 'The output is undefined'