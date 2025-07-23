# OIDC Identity Provider for GitHub
resource "aws_iam_openid_connect_provider" "github" {
  url = var.github_oidc_url

  client_id_list = [
    var.github_oidc_client_id
  ]

  thumbprint_list = [
    var.github_oidc_thumbprint
  ]
}

# Terraform admin role to be assumed by github_actions_role
resource "aws_iam_role" "terraform_admin_role" {
  name = var.terraform_admin_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_role.github_actions_role.arn
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_admin_attach" {
  role       = aws_iam_role.terraform_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


# IAM Role that GitHub Actions can assume via OIDC
resource "aws_iam_role" "github_actions_role" {
  name = var.github_actions_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = local.github_actions_repo_sub
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "github_actions_policy" {
  name = var.github_actions_policy_name
  role = aws_iam_role.github_actions_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sts:GetCallerIdentity"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Resource = aws_iam_role.terraform_admin_role.arn
      }
    ]
  })
}

