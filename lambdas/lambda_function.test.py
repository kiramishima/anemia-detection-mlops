import logging
import unittest

logger = logging.getLogger()

handler = function.lambda_handler

class TestFunction(unittest.TestCase):
    def test_function(self):
        