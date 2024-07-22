import os
import logging
import model

logger = logging.getLogger()
logger.setLevel(logging.INFO)

RUN_ID = os.getenv('RUN_ID')
TEST_RUN = os.getenv('TEST_RUN', 'False') == 'True'

model_service = model.init(
    run_id=RUN_ID,
    test_run=TEST_RUN,
)


def handler(event, context):
    logger.info(event)
    return model_service.lambda_handler(event)