terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
}

resource "aws_s3_bucket" "bucket" {
  bucket = "search-dev-terraform-backend"
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "sym-search-dev-terraform-lock"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}