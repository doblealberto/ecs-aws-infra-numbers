

provider "aws" {
  region  = "us-east-1"
  version = "~> 2.54.0"
}

locals {
  prefix = var.prefix
  common_tags = {
    Environment = terraform.workspace
    Project     = var.project
    Owner       = var.contact
    ManagedBy   = "Terraform"
  }
}


terraform {
  backend "s3" {
    bucket         = "final-project-challenge-number-app"
    key            = "terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "final-challenge-table"
  }
  required_version = ">= 0.13" 
}

data "aws_region" "current" {}
