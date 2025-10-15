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

# Default VPC
data "aws_vpc" "default" {
  default = true
}

# Generate SSH key pair
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair
resource "aws_key_pair" "deployer" {
  key_name   = "${var.project_name}-key-${var.environment}"
  public_key = tls_private_key.key.public_key_openssh

  tags = {
    Name        = "${var.project_name}-key"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Store private key locally (for SSH access)
resource "local_file" "private_key" {
  content         = tls_private_key.key.private_key_pem
  filename        = "${path.module}/keys/${var.project_name}-key.pem"
  file_permission = "0600"
}

# Security Group for EC2 instance
resource "aws_security_group" "forum" {
  name_prefix = "${var.project_name}-"
  description = "Security group for Forum Anonyme application"
  vpc_id      = data.aws_vpc.default.id

  # HTTP access for Thread service (port 80)
  ingress {
    description = "HTTP Thread Service"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access for API service (port 3000)
  ingress {
    description = "HTTP API Service"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access for Sender service (port 8080)
  ingress {
    description = "HTTP Sender Service"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-sg"
    Environment = var.environment
    Project     = var.project_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IP for stable public IP
resource "aws_eip" "forum" {
  instance = aws_instance.forum.id
  domain   = "vpc"

  tags = {
    Name        = "${var.project_name}-eip"
    Environment = var.environment
    Project     = var.project_name
  }

  depends_on = [aws_instance.forum]
}

# EC2 Instance
resource "aws_instance" "forum" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.forum.id]

  # Root volume configuration
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true

    tags = {
      Name        = "${var.project_name}-root-volume"
      Environment = var.environment
    }
  }

  # User data script to install Docker and deploy application
  user_data = templatefile("${path.module}/scripts/user_data.sh", {
    docker_image_tag    = var.docker_image_tag
    github_repository   = var.github_repository
    db_password         = var.db_password
    project_name        = var.project_name
  })

  # Enable detailed monitoring
  monitoring = true

  # Metadata options for security
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  tags = {
    Name        = "${var.project_name}-instance"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}
