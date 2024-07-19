import logging
import unittest
import json
import lambda_function

logger = logging.getLogger()

handler = lambda_function.lambda_handler

class TestFunction(unittest.TestCase):
    def test_function(self):
        try:
            with open('data.json') as f:
                data = json.load(f)

            logger.info(data)
            context = {'requestid' : '1234'}
            result = handler(data[0], context)
            print(str(result))

            self.assertEqual(1, result['predict'])
        finally:
            print('')

if __name__ == '__main__':
    unittest.main()