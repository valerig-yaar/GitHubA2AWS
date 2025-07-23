# S3 Bucket for TF state
resource "aws_s3_bucket" "tf_state" {
  bucket        = var.tf_state_bucket_name
  force_destroy = var.tf_state_bucket_force_destroy

  lifecycle {
    prevent_destroy = true
  }
}

# Enable versioning separately
resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Optional: Enable default encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_encryption" {
  bucket = aws_s3_bucket.tf_state.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.tf_state_bucket_encryption_algorithm
    }
  }
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "tf_locks" {
  name         = var.tf_locks_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }
}