# Terraform Block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.66.1"
    }
  }
  backend "s3" {
    encrypt        = true
    bucket         = "terraform-aero-api-state"
    dynamodb_table = "terraform"
    region         = "us-east-1"
  }

}

# Provider Block
provider "aws" {
  region  = "us-east-1"
}

