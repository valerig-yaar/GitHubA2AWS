# bootstrap.tf
provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      Terraform   = "true"
      Environment = "dev"
      Owner       = "ValeriG"
    }
  }
}

terraform {
  backend "s3" {
    bucket         = "REPLACE_ME"
    key            = "github-oidc/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "REPLACE_ME"
    encrypt        = true
  }
}
