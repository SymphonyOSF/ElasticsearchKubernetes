variable "region" {
  description = "AWS region"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket's name"
  type        = string
}

variable "dynamodb_table_lock_name" {
  description = "DynamoDB lock table name"
  type        = string
}
