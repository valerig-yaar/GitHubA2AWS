variable "tf_state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  default     = "terraform-state-bucket-vg"
}

variable "tf_state_bucket_force_destroy" {
  description = "Allow force destroy of the S3 bucket"
  type        = bool
  default     = false
}

variable "tf_state_bucket_encryption_algorithm" {
  description = "SSE algorithm for S3 bucket encryption"
  type        = string
  default     = "AES256"
}

variable "tf_locks_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "terraform-state-locks"
}

variable "github_oidc_url" {
  description = "OIDC provider URL for GitHub Actions"
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}

variable "github_oidc_thumbprint" {
  description = "Root CA thumbprint for GitHub OIDC"
  type        = string
  default     = "6938fd4d98bab03faadb97b34396831e3780aea1"
}

variable "github_oidc_client_id" {
  description = "Client ID for OIDC provider"
  type        = string
  default     = "sts.amazonaws.com"
}

variable "terraform_admin_role_name" {
  description = "Name of the Terraform admin role"
  type        = string
  default     = "terraform-admin-role"
}

variable "github_actions_role_name" {
  description = "IAM role name for GitHub Actions"
  type        = string
  default     = "github-actions-oidc-role"
}

variable "github_actions_policy_name" {
  description = "IAM policy name for GitHub Actions role"
  type        = string
  default     = "github-actions-basic-policy"
}

variable "github_org" {
  description = "GitHub organization or user"
  type        = string
  default = "valerig-yaar"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default = "*"
}

variable "github_ref_type" {
  description = "Git ref type: heads for branches, tags for tags"
  type        = string
  default     = "*"
}

variable "github_branch_pattern" {
  description = "Branch pattern for OIDC sub claim"
  type        = string
  default     = "*"
}

variable "allow_pr" {
  description = "Allow pull requests to trigger the GitHub Actions role"
  type        = bool
  default     = true
}

locals {
  github_actions_repo_sub = "repo:${var.github_org}/${var.github_repo}:ref:refs/${var.github_ref_type}/${var.github_branch_pattern}"
  github_actions_repo_pr = var.allow_pr ? "repo:${var.github_org}/${var.github_repo}:pull_request" : null
}
