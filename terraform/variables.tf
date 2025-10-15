variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "forum-anonyme"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "instance_type" {
  description = "EC2 instance type (t2/t3 nano or micro only)"
  type        = string
  default     = "t2.micro"

  validation {
    condition     = can(regex("^t[2-3]\\.(nano|micro)$", var.instance_type))
    error_message = "Instance type must be t2.nano, t2.micro, t3.nano, or t3.micro as per AWS educational account restrictions."
  }
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Database configuration (PostgreSQL in Docker container)
variable "db_password" {
  description = "Database password for PostgreSQL"
  type        = string
  sensitive   = true
  default     = "SecureForumPassword2024!"

  validation {
    condition     = length(var.db_password) >= 8
    error_message = "Database password must be at least 8 characters long."
  }
}

# Application configuration
variable "docker_image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

variable "github_repository" {
  description = "GitHub repository name (lowercase)"
  type        = string
  default     = "itsmelouis/forum-anonyme"
}
