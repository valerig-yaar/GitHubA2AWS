
# Terraform AWS Bootstrap Project

This repository contains Terraform code and GitHub Actions workflows to bootstrap infrastructure and validate OpenID Connect (OIDC) integration with AWS.

## ⚙️ Prerequisites

- Terraform >= 1.3
- AWS CLI with a configured profile **OR** static AWS credentials
- GitHub repository access (to manage secrets or configure workflows)
- AWS account with permission to:
  - Create and manage IAM resources
  - Create S3 buckets and DynamoDB tables (for state backend)

---

## 🚀 First Run Instructions (Local Setup)

The Terraform backend (S3 + DynamoDB) must be provisioned **before** using it in your configuration.

### Step 1: Run Locally Without Backend

1. Ensure you have valid AWS credentials:
   - Either via `aws configure`
   - Or set environment variables:
     ```bash
     export AWS_ACCESS_KEY_ID=...
     export AWS_SECRET_ACCESS_KEY=...
     ```

2. **Do not uncomment the `terraform { backend "s3" { ... } }` block yet.**

3. Run Terraform locally to create the backend resources:

   ```bash
   terraform init
   terraform apply
   ```

This will create the S3 bucket and DynamoDB table for storing remote Terraform state.

### Step 2: Enable Remote State Backend

1. After the resources are created, uncomment the backend block in `bootstrap.tf`:

   ```hcl
    terraform {
      backend "s3" {
        bucket         = "REPLACE_ME"
        key            = "PROJECT_NAME/terraform.tfstate"
        region         = "us-east-1"
        dynamodb_table = "REPLACE_ME"
        encrypt        = true
      }
    }
   ```

2. Re-initialize Terraform to migrate to the backend:

   ```bash
   terraform init -migrate-state \
    -backend-config="bucket=${TF_VAR_tf_state_bucket_name}" \
    -backend-config="dynamodb_table=${TF_VAR_tf_locks_table_name}" \
    -backend-config="region=${TF_VAR_region}"
   ```
---

## 🔐 Required GitHub Secrets

After the initial local apply, populate the following GitHub secrets:

| Secret Name             | Description                             |
| ----------------------- | --------------------------------------- |
| `AWS_REGION`            | AWS region for deployment               |
| `AWS_ROLE_TO_ASSUME`    | IAM Role ARN to assume via OIDC         |
| `AWS_ROLE_TO_ASSUME_TF` | IAM Role ARN to assume via OIDC fot TF  |
| `TF_STATE_BUCKET_NAME`  | Terraform state bucket                  |
| `TF_LOCKS_TABLE_NAME`   | DynamoDB lock table for state           |

These secrets are used by the GitHub Actions workflows defined in `.github/workflows/`.

---

## 🔄 Alternatives for Authentication

You can switch between these authentication methods based on your use case:

### 1. Static AWS Credentials via GitHub Secrets

Store the following secrets:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`

Update the GitHub workflows to use `aws-actions/configure-aws-credentials` with `access-key` method.

### 2. Self-hosted Runners (with IAM Role access)

Use EC2 or another internal runner that already has proper AWS IAM permissions assigned via instance profile.

Advantages:

* No secrets required in GitHub
* Access policies controlled via IAM

### 3. OIDC with Role Assumption (Recommended)

Configure a trust policy in your AWS IAM role to allow GitHub's OIDC provider (`token.actions.githubusercontent.com`) to assume the role.

In `provider.tf`, use:

```hcl
provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.assume_role_arn
  }
}
```

GitHub Actions will authenticate using OIDC and assume this role to deploy resources securely.

---

## 📁 Files Overview

| File                                     | Purpose                                |
| ---------------------------------------- | -------------------------------------- |
| `main.tf`                                | Core infrastructure resources          |
| `provider.tf`                            | AWS provider configuration             |
| `variables.tf`                           | Input variables                        |
| `bootstrap.tf`                           | Backend setup (S3 + DynamoDB)          |
| `terraform.yaml`                         | Main GitHub Action for Terraform apply |
| `github-action-aws-oidc-validation.yaml` | Validates OIDC trust with AWS          |

---

## 🏗️ Resources

The following AWS resources will be created by this project:

| Resource Type       | Purpose                                              | Notes                                 |
|---------------------|------------------------------------------------------|----------------------------------------|
| `aws_s3_bucket`     | Stores Terraform remote state                        | Name provided via `tf_state_bucket_name` variable |
| `aws_dynamodb_table`| Handles Terraform state locking                      | Name provided via `tf_locks_table_name` variable |
| `aws_iam_role`      | Role for GitHub OIDC integration                     | Used in CI pipelines via trust relationship |
| `aws_iam_policy`    | Inline/external policies for the IAM role            | Grants permissions to deploy infrastructure |
| `aws_iam_role_policy_attachment` | Binds policy to role                    | Required for GitHub to assume role via OIDC |

Additional resources may be added depending on how `main.tf` is extended for actual infrastructure provisioning.


---

## 🧹 Uninstall

#### 1. **Migrate state from remote (S3) to local**

```bash
terraform state pull > terraform.tfstate
```

This saves the latest remote state **locally** into `terraform.tfstate`.

---

#### 2. **Reconfigure backend to local**

Update your `terraform` block like this (or comment it):

```hcl
terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}
```

Then reinitialize:

```bash
terraform init -migrate-state
```
---

#### 3. **Delete S3 bucket and DynamoDB table**

Make sure the bucket is empty:

```bash
aws s3api list-object-versions \
  --bucket REPLACE_WITH_YOUR_BUCKET \
  --query "Versions[].{Key:Key,VersionId:VersionId}" \
  --output json | jq '{Objects: .}' > /tmp/delete.json
  
aws s3api delete-objects --bucket REPLACE_WITH_YOUR_BUCKET --delete file:///tmp/delete.json

````
---

#### 4. **Destroy infrastructure**

Now that the backend is local and state is safe, destroy:

```bash
terraform destroy
```

This removes:

* The IAM role
* OIDC provider
* Any related infra (not the bucket yet)


> ⚠️ Important: If remote backend is configured, ensure you still have valid access to the state before destroying.

---




