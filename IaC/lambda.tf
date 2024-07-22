# lambda.tf | Lambda Function Configuration

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "../lambdas/"
  output_path = "${path.module}/python/lambda_handler.zip"
}

resource "aws_lambda_function" "terraform_lambda_func" {
  filename      = "${path.module}/python/event_handler.zip"
  function_name = "${var.app_name}-anemia-service"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.handler"
  runtime       = "python3.12"
  depends_on = [aws_iam_role_policy_attachment.attach_iam_policy_to_lambda_role,
  aws_alb.application_load_balancer]

  environment {
    variables = {
      MAGE_API_HOST = aws_alb.application_load_balancer.dns_name,
      RUN_ID        = "Mage will update this",
      MODEL_BUCKET  = var.models_bucket_name
    }
  }
}