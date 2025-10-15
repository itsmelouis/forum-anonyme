# Backend configuration for Terraform state
# For production, you should use a remote backend like S3
# For now, we use local backend (default)

# Uncomment and configure if you want to use S3 backend:
# terraform {
#   backend "s3" {
#     bucket         = "forum-anonyme-terraform-state"
#     key            = "terraform.tfstate"
#     region         = "eu-west-3"
#     encrypt        = true
#     dynamodb_table = "terraform-state-lock"
#   }
# }
