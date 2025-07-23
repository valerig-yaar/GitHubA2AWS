output "tf_state_bucket_name" {
  description = "Name of the S3 bucket used for Terraform state"
  value       = aws_s3_bucket.tf_state.bucket
}

output "tf_locks_table_name" {
  description = "Name of the DynamoDB table used for state locking"
  value       = aws_dynamodb_table.tf_locks.name
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions IAM role"
  value       = aws_iam_role.github_actions_role.arn
}

output "terraform_admin_role_arn" {
  description = "ARN of the Terraform admin IAM role"
  value       = aws_iam_role.terraform_admin_role.arn
}