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
logger.info(RUN_ID, TEST_RUN)
logger.info(model_service)


def handler(event, context):
    logger.info(event)
    print(event)
    print(str(event))
    return model_service.lambda_handler(event)