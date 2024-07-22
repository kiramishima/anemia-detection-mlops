# s3.tf | AWS S3

resource "aws_s3_bucket" "model_bucket" {
  bucket        = var.models_bucket_name
  force_destroy = true
  tags = {
    Name        = "${var.app_name}-buckets"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "reports_bucket" {
  bucket        = var.evidently_bucket_name
  force_destroy = true
  tags = {
    Name        = "${var.app_name}-buckets"
    Environment = "Dev"
  }
}