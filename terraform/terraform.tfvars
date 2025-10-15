# AWS Configuration
aws_region = "eu-central-1"

# Project Configuration
project_name = "forum-anonyme"
environment  = "production"

# EC2 Configuration - Using t2.micro as per AWS educational account restrictions
instance_type = "t2.micro"

# Security Configuration
allowed_ssh_cidr = ["0.0.0.0/0"]

# Database Configuration (PostgreSQL in Docker container)
db_password = "SecureForumPassword2024!"

# Application Configuration
docker_image_tag  = "latest"
github_repository = "itsmelouis/forum-anonyme"
