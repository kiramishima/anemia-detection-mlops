# sg.tf | Security Group Configuration

resource "aws_security_group" "service_security_group" {
  vpc_id = aws_vpc.aws-vpc.id

  ingress {
    from_port       = 6789
    to_port         = 6789
    protocol        = "tcp"
    cidr_blocks     = ["${chomp(data.http.myip.response_body)}/32"]
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    cidr_blocks     = ["${chomp(data.http.myip.response_body)}/32"]
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    cidr_blocks     = ["${chomp(data.http.myip.response_body)}/32"]
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.app_name}-service-sg"
    Environment = var.app_environment
  }
}