terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# Data sources
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Generate SSH key pair
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair
resource "aws_key_pair" "deployer" {
  key_name   = "floquet-louis-${var.project_name}-key-${var.environment}"
  public_key = tls_private_key.key.public_key_openssh

  tags = {
    Name        = "floquet-louis-${var.project_name}-key"
    Environment = var.environment
    Project     = var.project_name
    Owner       = "floquet-louis"
  }
}

# Store private key locally (for SSH access)
resource "local_file" "private_key" {
  content         = tls_private_key.key.private_key_pem
  filename        = "${path.module}/keys/floquet-louis-${var.project_name}-key.pem"
  file_permission = "0600"
}

# Security Group for API (port 3000)
resource "aws_security_group" "api" {
  name_prefix = "floquet-louis-${var.project_name}-api-"
  description = "Security group for API service"

  ingress {
    description = "HTTP API"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "floquet-louis-${var.project_name}-api-sg"
    Service = "api"
    Owner   = "floquet-louis"
  }
}

# Security Group for Thread (port 80)
resource "aws_security_group" "thread" {
  name_prefix = "floquet-louis-${var.project_name}-thread-"
  description = "Security group for Thread service"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "floquet-louis-${var.project_name}-thread-sg"
    Service = "thread"
    Owner   = "floquet-louis"
  }
}

# Security Group for Sender (port 80)
resource "aws_security_group" "sender" {
  name_prefix = "floquet-louis-${var.project_name}-sender-"
  description = "Security group for Sender service"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "floquet-louis-${var.project_name}-sender-sg"
    Service = "sender"
    Owner   = "floquet-louis"
  }
}

# Security Group for DB (port 5432)
resource "aws_security_group" "db" {
  name_prefix = "floquet-louis-${var.project_name}-db-"
  description = "Security group for Database service"

  ingress {
    description = "PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "floquet-louis-${var.project_name}-db-sg"
    Service = "db"
    Owner   = "floquet-louis"
  }
}

# EC2 Instance for API
resource "aws_instance" "api" {
  ami             = data.aws_ami.amazon_linux_2.id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.api.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              docker run -d -p 3000:3000 --name api \
                -e DATABASE_URL=postgresql://forum:${var.db_password}@${aws_instance.db.public_ip}:5432/forumdb \
                ghcr.io/${var.github_repository}/api:${var.docker_image_tag}
              EOF

  tags = {
    Name    = "floquet-louis-${var.project_name}-api"
    Service = "api"
    Owner   = "floquet-louis"
  }
}

# EC2 Instance for Thread
resource "aws_instance" "thread" {
  ami             = data.aws_ami.amazon_linux_2.id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.thread.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              docker run -d -p 80:80 --name thread \
                -e API_URL=http://${aws_instance.api.public_ip}:3000 \
                -e SENDER_URL=http://${aws_instance.sender.public_ip} \
                ghcr.io/${var.github_repository}/thread:${var.docker_image_tag}
              EOF

  tags = {
    Name    = "floquet-louis-${var.project_name}-thread"
    Service = "thread"
    Owner   = "floquet-louis"
  }

  depends_on = [aws_instance.api]
}

# EC2 Instance for Sender
resource "aws_instance" "sender" {
  ami             = data.aws_ami.amazon_linux_2.id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.sender.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              docker run -d -p 80:80 --name sender \
                -e API_URL=http://${aws_instance.api.public_ip}:3000 \
                ghcr.io/${var.github_repository}/sender:${var.docker_image_tag}
              EOF

  tags = {
    Name    = "floquet-louis-${var.project_name}-sender"
    Service = "sender"
    Owner   = "floquet-louis"
  }

  depends_on = [aws_instance.api]
}

# EC2 Instance for Database
resource "aws_instance" "db" {
  ami             = data.aws_ami.amazon_linux_2.id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.db.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              docker run -d -p 5432:5432 --name postgres \
                -e POSTGRES_USER=forum \
                -e POSTGRES_PASSWORD=${var.db_password} \
                -e POSTGRES_DB=forumdb \
                postgres:16
              EOF

  tags = {
    Name    = "floquet-louis-${var.project_name}-db"
    Service = "db"
    Owner   = "floquet-louis"
  }
}
