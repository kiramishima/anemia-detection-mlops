# AWS Conf
variable "AWS_ACCESS_KEY_ID" {
  type    = string
  default = "AWS_ACCESS_KEY_ID"
}

variable "AWS_SECRET_ACCESS_KEY" {
  type    = string
  default = "AWS_SECRET_ACCESS_KEY"
}

variable "AWS_REGION" {
  description = "Region"
  #Update the below to your desired region
  default = "us-east-1"
}

# Services conf
variable "DATABASE_CONNECTION_URL" {
  type    = string
  default = ""
}

variable "EXPERIMENT_NAME" {
  type    = string
  default = "LR-Anemia-model"
}

variable "RUN_ID" {
  type        = string
  description = "EXPERIMENT ID from MLFLOW"
}

variable "models_bucket_name" {
  description = "Name of the Models Bucket"
  #Update the below to a unique bucket name
  default = "mlflow-anemia-models"
}

variable "evidently_bucket_name" {
  description = "Name of the Reports Bucket"
  #Update the below to a unique bucket name
  default = "evidently-workspace"
}

variable "app_name" {
  type        = string
  description = "Application Name"
  default     = "anemia-mlops"
}

variable "app_environment" {
  type        = string
  description = "Application Environment"
  default     = "production"
}

# Subnet
variable "cidr" {
  description = "The CIDR block for the VPC."
  default     = "10.32.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnets"
  default     = ["10.32.100.0/24", "10.32.101.0/24"]
}

variable "private_subnets" {
  description = "List of private subnets"
  default     = ["10.32.0.0/24", "10.32.1.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  default     = ["us-west-2a", "us-west-2b"]
}

# Database
variable "DB_USER" {
  type        = string
  description = "The username of the Postgres database."
  default     = "drwho"
}

variable "DB_PASSWORD" {
  type        = string
  description = "The password of the Postgres database."
  sensitive   = true
}

# Containers
variable "docker_image" {
  description = "Docker image url used in ECS task."
  default     = "mageai/mageai:alpha"
  type        = string
}

variable "ecr_repo_name" {
  type        = string
  description = "ECR repo name"
}

variable "ecr_image_tag" {
  type        = string
  description = "ECR repo name"
  default     = "latest"
}

variable "ecs_task_cpu" {
  description = "ECS task cpu"
  default     = 4096
}

variable "ecs_task_memory" {
  description = "ECS task memory"
  default     = 8192
}

variable "account_id" {
}

variable "project_id" {
  description = "project_id"
  default     = "anemia-mlops"
}

variable "lambda_function_local_path" {
  description = ""
}

variable "docker_mage_image_local_path" {
  description = ""
  default     = "../Workspace"
}

variable "lambda_function_name" {
  description = ""
}