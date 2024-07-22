# db.tf | Database Configuration

resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "${var.app_name}-${var.app_environment}-rds-subnet-group"
  description = "${var.app_name} RDS subnet group"
  subnet_ids  = aws_subnet.public.*.id
  tags = {
    Environment = var.app_environment
  }
}


resource "aws_security_group" "rds_sg" {
  name        = "${var.app_name}-${var.app_environment}-rds-sg"
  description = "${var.app_name} RDS Security Group"
  vpc_id      = aws_vpc.aws-vpc.id

  tags = {
    Name        = "${var.app_name}-${var.app_environment}-rds-sg"
    Environment = var.app_environment
  }

  // allows traffic from the SG itself
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  //allow traffic for TCP 5432
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = ["${aws_security_group.service_security_group.id}"]
  }

  // outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "rds" {
  identifier             = "${var.app_name}-${var.app_environment}-db"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = "db.t3.micro"
  multi_az               = false
  db_name                = "mlops"
  username               = var.DB_USER     // export TF_VAR_DB_USER="..."
  password               = var.DB_PASSWORD // export TF_VAR_DB_PASSWORD="..."
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.id
  vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]
  skip_final_snapshot    = true
  publicly_accessible    = true

  tags = {
    Environment = var.app_environment
  }
}

resource "null_resource" "db_setup" {
  # runs after database and security group providing external access is created
  depends_on = [aws_db_instance.rds, aws_security_group.rds_sg]

  provisioner "local-exec" {
    command = "psql -h \"${aws_db_instance.rds.address}\" -u \"${var.DB_USER}\" -p \"${var.DB_PASSWORD}\" -d \"${aws_db_instance.rds.db_name}\" -f init-db.sql"
    environment = {
      # for instance, postgres would need the password here:
      PGPASSWORD = "${var.DB_PASSWORD}"
    }
  }
}