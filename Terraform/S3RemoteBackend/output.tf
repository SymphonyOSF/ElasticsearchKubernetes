output "S3_BUCKET_ID" {
  value = aws_s3_bucket.bucket.id
}

output "DYNAMODB_TABLE_LOCK_NAME" {
  value = aws_dynamodb_table.terraform_state_lock.name
}
