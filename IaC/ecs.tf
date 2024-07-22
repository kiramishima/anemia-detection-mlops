resource "aws_ecs_task_definition" "aws-ecs-mlflow-task" {
  family = "${var.app_name}-task"

  container_definitions = <<DEFINITION
  [
    {
      "name": "${var.app_name}-${var.app_environment}-mlflow-container",
      "image": "${aws_ecr_repository.container_repository.repository_url}-mlflow:${var.ecr_image_tag}",
      "environment": {
        "ENV": "${var.app_environment}",
        "S3_URI": "s3://${var.models_bucket_name}/",
        "DB_URI": "postgresql://${aws_db_instance.rds.username}:${aws_db_instance.rds.password}@${aws_db_instance.rds.address}:5432/mlflow"
      },
      "essential": true,
      "mountPoints": [
        {
          "readOnly": false,
          "containerPath": "/home/src",
          "sourceVolume": "${var.models_bucket_name}"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log-group.id}",
          "awslogs-region": "${var.AWS_REGION}",
          "awslogs-stream-prefix": "${var.app_name}-${var.app_environment}"
        }
      },
      "portMappings": [
        {
          "containerPort": 5000,
          "hostPort": 5000
        }
      ],
      "cpu": ${var.ecs_task_cpu},
      "memory": ${var.ecs_task_memory},
      "networkMode": "awsvpc",
      "ulimits": [
        {
          "name": "nofile",
          "softLimit": 16384,
          "hardLimit": 32768
        }
      ]
    }
  ]
  DEFINITION

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.ecs_task_memory
  cpu                      = var.ecs_task_cpu
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn

  volume {
    name = var.models_bucket_name

    docker_volume_configuration {
      driver = "s3fs"
      driver_opts = {
        "s3Url" : "https://s3.amazonaws.com/${var.models_bucket_name}",
        "accessKeyId" : "${var.AWS_ACCESS_KEY_ID}",
        "secretAccessKey" : "${var.AWS_SECRET_ACCESS_KEY}"
      }
    }
  }

  tags = {
    Name        = "${var.app_name}-ecs-td"
    Environment = var.app_environment
  }

  # depends_on = [aws_lambda_function.terraform_lambda_func]
}

resource "aws_ecs_task_definition" "aws-ecs-evidently-task" {
  family = "${var.app_name}-task"

  container_definitions = <<DEFINITION
  [
    {
      "name": "${var.app_name}-${var.app_environment}-container",
      "image": "${aws_ecr_repository.container_repository.repository_url}-evidently:${var.ecr_image_tag}",
      "environment": {
        "ENV": "${var.app_environment}",
        "S3_WS": "s3://${var.evidently_bucket_name}/"
      },
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log-group.id}",
          "awslogs-region": "${var.AWS_REGION}",
          "awslogs-stream-prefix": "${var.app_name}-${var.app_environment}"
        }
      },
      "portMappings": [
        {
          "containerPort": 8000,
          "hostPort": 8000
        }
      ],
      "cpu": ${var.ecs_task_cpu},
      "memory": ${var.ecs_task_memory},
      "networkMode": "awsvpc",
      "ulimits": [
        {
          "name": "nofile",
          "softLimit": 16384,
          "hardLimit": 32768
        }
      ]
    }
  ]
  DEFINITION

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.ecs_task_memory
  cpu                      = var.ecs_task_cpu
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn

  volume {
    name = var.evidently_bucket_name

    docker_volume_configuration {
      driver = "s3fs"
      driver_opts = {
        "s3Url" : "https://s3.amazonaws.com/${var.evidently_bucket_name}",
        "accessKeyId" : "${var.AWS_ACCESS_KEY_ID}",
        "secretAccessKey" : "${var.AWS_SECRET_ACCESS_KEY}"
      }
    }
  }

  tags = {
    Name        = "${var.app_name}-ecs-td"
    Environment = var.app_environment
  }

  # depends_on = [aws_lambda_function.terraform_lambda_func]
}
# Containers in Fargate tasks share a network namespace, so you don't need to use links at all. You can simply communicate via localhost.
resource "aws_ecs_task_definition" "aws-ecs-mage-task" {
  family = "${var.app_name}-task"

  container_definitions = <<DEFINITION
  [
    {
      "name": "${var.app_name}-${var.app_environment}-container",
      "image": "${aws_ecr_repository.container_repository.repository_url}-mage:${var.ecr_image_tag}",
      "environment": {
        "ENV": "${var.app_environment}",
        "SOURCE_URL": "https://raw.githubusercontent.com/kiramishima/anemia-detection-mlops/master/DATA/anemia_dataset.csv",
        "EVIDENTLY_HOST": "http://localhost:8000",
        "TRACKING_URI": "http://localhost:5000",
        "EXPERIMENT_NAME": "${var.EXPERIMENT_NAME}",
        "MAGE_CODE_PATH": "/home/src",
        "POSTGRES_HOST": "${aws_db_instance.rds.address}",
        "POSTGRES_DB": \"mage\",
        "POSTGRES_PASSWORD": "${aws_db_instance.rds.password}",
        "POSTGRES_USER": "${aws_db_instance.rds.username}",
        "MAGE_DATABASE_CONNECTION_URL": "postgresql+psycopg2://${aws_db_instance.rds.username}:${aws_db_instance.rds.password}@${aws_db_instance.rds.address}:5432/mage",
      },
      "essential": true,
      "mountPoints": [
        {
          "readOnly": false,
          "containerPath": "/home/src",
          "sourceVolume": "${var.models_bucket_name}"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log-group.id}",
          "awslogs-region": "${var.AWS_REGION}",
          "awslogs-stream-prefix": "${var.app_name}-${var.app_environment}"
        }
      },
      "portMappings": [
        {
          "containerPort": 6789,
          "hostPort": 6789
        }
      ],
      "cpu": ${var.ecs_task_cpu},
      "memory": ${var.ecs_task_memory},
      "networkMode": "awsvpc",
      "ulimits": [
        {
          "name": "nofile",
          "softLimit": 16384,
          "hardLimit": 32768
        }
      ],
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost:6789/api/status || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 10
      }
    }
  ]
  DEFINITION

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.ecs_task_memory
  cpu                      = var.ecs_task_cpu
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn

  volume {
    name = var.models_bucket_name

    docker_volume_configuration {
      driver = "s3fs"
      driver_opts = {
        "s3Url" : "https://s3.amazonaws.com/${var.models_bucket_name}",
        "accessKeyId" : "${var.AWS_ACCESS_KEY_ID}",
        "secretAccessKey" : "${var.AWS_SECRET_ACCESS_KEY}"
      }
    }
  }

  tags = {
    Name        = "${var.app_name}-ecs-td"
    Environment = var.app_environment
  }

  depends_on = [aws_ecs_task_definition.aws-ecs-evidently-task, aws_ecs_task_definition.aws-ecs-mlflow-task]
}

data "aws_ecs_task_definition" "main-mlflow" {
  task_definition = aws_ecs_task_definition.aws-ecs-mlflow-task.family
}

resource "aws_ecs_service" "aws-ecs-mlflow-service" {
  name                 = "${var.app_name}-${var.app_environment}-ecs-mlflow-service"
  cluster              = aws_ecs_cluster.aws-ecs-cluster.id
  task_definition      = "${aws_ecs_task_definition.aws-ecs-mlflow-task.family}:${max(aws_ecs_task_definition.aws-ecs-mlflow-task.revision, data.aws_ecs_task_definition.main-mlflow.revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = aws_subnet.public.*.id
    assign_public_ip = true
    security_groups = [
      aws_security_group.service_security_group.id,
      aws_security_group.load_balancer_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "${var.app_name}-${var.app_environment}-mlflow-container"
    container_port   = 5000
  }

  depends_on = [aws_lb_listener.listener]
}

data "aws_ecs_task_definition" "main-evidently" {
  task_definition = aws_ecs_task_definition.aws-ecs-evidently-task.family
}

resource "aws_ecs_service" "aws-ecs-evidently-service" {
  name                 = "${var.app_name}-${var.app_environment}-ecs-evidently-service"
  cluster              = aws_ecs_cluster.aws-ecs-cluster.id
  task_definition      = "${aws_ecs_task_definition.aws-ecs-evidently-task.family}:${max(aws_ecs_task_definition.aws-ecs-evidently-task.revision, data.aws_ecs_task_definition.main-evidently.revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = aws_subnet.public.*.id
    assign_public_ip = true
    security_groups = [
      aws_security_group.service_security_group.id,
      aws_security_group.load_balancer_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "${var.app_name}-${var.app_environment}-evidently-container"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.listener]
}

data "aws_ecs_task_definition" "main-mage" {
  task_definition = aws_ecs_task_definition.aws-ecs-mage-task.family
}

resource "aws_ecs_service" "aws-ecs-mage-service" {
  name                 = "${var.app_name}-${var.app_environment}-ecs-mage-service"
  cluster              = aws_ecs_cluster.aws-ecs-cluster.id
  task_definition      = "${aws_ecs_task_definition.aws-ecs-mage-task.family}:${max(aws_ecs_task_definition.aws-ecs-mage-task.revision, data.aws_ecs_task_definition.main-mage.revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = aws_subnet.public.*.id
    assign_public_ip = true
    security_groups = [
      aws_security_group.service_security_group.id,
      aws_security_group.load_balancer_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "${var.app_name}-${var.app_environment}-mage-container"
    container_port   = 6789
  }

  depends_on = [aws_lb_listener.listener]
}