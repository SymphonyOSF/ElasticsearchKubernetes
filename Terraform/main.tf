terraform {
  required_version = ">= 0.12.0"

  backend "s3" {
    bucket          = "search-dev-terraform-backend"
    encrypt         = true
    key             = "terraform.tfstate"
    region          = "us-east-1"
    dynamodb_table  = "sym-search-dev-terraform-lock"
  }
}

provider "aws" {
  version = ">= 2.38.0"
  region  = var.region
}