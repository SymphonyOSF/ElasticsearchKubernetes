terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">= 2.38.0"
  region  = var.region
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.s3_bucket_name
  region = var.region
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = var.dynamodb_table_lock_name
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}