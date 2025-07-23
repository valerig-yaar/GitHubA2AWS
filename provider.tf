# bootstrap.tf
provider "aws" {
  region = "us-east-1"
}

# terraform {
#   backend "s3" {
#     bucket         = "REPLACE_ME"
#     key            = "github-oidc/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "REPLACE_ME"
#     encrypt        = true
#   }
# }
