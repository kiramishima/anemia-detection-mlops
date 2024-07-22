# ecr.tf | Network Configuration

resource "aws_ecr_repository" "container_repository" {
  name                 = "${var.app_name}-${var.app_environment}-repository"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.app_name}-repository"
    Environment = var.app_environment
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "null_resource" "ecr_mage_image" {
  provisioner "local-exec" {
    command = <<EOF
             aws ecr get-login-password --region ${var.AWS_REGION} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.AWS_REGION}.amazonaws.com
             cd ../Workflow
             docker build -t ${aws_ecr_repository.container_repository.repository_url}-mage:${var.ecr_image_tag} -f Dockerfile .
             docker push ${aws_ecr_repository.container_repository.repository_url}-mage:${var.ecr_image_tag}
         EOF
  }
}

resource "null_resource" "ecr_mlflow_image" {
  provisioner "local-exec" {
    command = <<EOF
             aws ecr get-login-password --region ${var.AWS_REGION} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.AWS_REGION}.amazonaws.com
             cd ../Workflow
             docker build -t ${aws_ecr_repository.container_repository.repository_url}-mlflow:${var.ecr_image_tag} -f mlflow.Dockerfile .
             docker push ${aws_ecr_repository.container_repository.repository_url}-mlflow:${var.ecr_image_tag}
         EOF
  }
}

resource "null_resource" "ecr_evidently_image" {

  provisioner "local-exec" {
    command = <<EOF
             aws ecr get-login-password --region ${var.AWS_REGION} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.AWS_REGION}.amazonaws.com
             cd ../Workflow
             docker build -t ${aws_ecr_repository.container_repository.repository_url}-evidently:${var.ecr_image_tag} -f evidently.Dockerfile .
             docker push ${aws_ecr_repository.container_repository.repository_url}-evidently:${var.ecr_image_tag}
         EOF
  }
}

// Wait for the image to be uploaded, before lambda config runs
data "aws_ecr_image" "lambda_image" {
  depends_on = [
    null_resource.ecr_mage_image,
    null_resource.ecr_mlflow_image,
    null_resource.ecr_evidently_image
  ]
  repository_name = var.ecr_repo_name
  image_tag       = var.ecr_image_tag
}