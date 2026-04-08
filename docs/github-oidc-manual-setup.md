# GitHub OIDC Manual IAM Setup (Option 1)

This guide documents the one-time manual IAM setup for GitHub Actions.

In this repository's Option 1 model:
- `infra/bootstrap` creates only backend resources (S3 + DynamoDB).
- The GitHub Actions IAM role is created manually in AWS.
- GitHub Actions assumes that role using OIDC.

## 1. Create or Verify OIDC Provider in AWS IAM

In AWS IAM, ensure this OIDC provider exists:
- Provider URL: `https://token.actions.githubusercontent.com`
- Audience: `sts.amazonaws.com`

Provider ARN format:
- `arn:aws:iam::<account-id>:oidc-provider/token.actions.githubusercontent.com`

## 2. Create IAM Role for GitHub Actions

Create an IAM role with trusted entity type **Web identity** and use the trust policy below.

Trust relationship policy used by this project:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<account-id>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": [
            "repo:<github-owner>/<github-repo>:pull_request",
            "repo:<github-owner>/<github-repo>:ref:refs/heads/main"
          ]
        }
      }
    }
  ]
}
```

Replace placeholders (`<account-id>`, `<github-owner>`, `<github-repo>`) with your own values.

Notes:
- `pull_request` allows PR workflows to assume the role.
- `ref:refs/heads/main` allows main-branch workflows.
- Keep subjects as narrow as possible for least privilege.

## 3. Attach IAM Permissions Policy

permissions policy used by this project:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "iam:GetPolicyVersion",
        "elasticloadbalancing:ModifyListener",
        "iam:CreateRole",
        "iam:AttachRolePolicy",
        "iam:PutRolePolicy",
        "elasticloadbalancing:DeleteLoadBalancer",
        "ecs:UpdateService",
        "iam:DetachRolePolicy",
        "iam:ListAttachedRolePolicies",
        "ecs:RegisterTaskDefinition",
        "elasticloadbalancing:CreateRule",
        "logs:DeleteRetentionPolicy",
        "elasticloadbalancing:Describe*",
        "iam:ListRolePolicies",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "ecs:TagResource",
        "iam:GetRole",
        "iam:GetPolicy",
        "ecs:CreateCluster",
        "elasticloadbalancing:CreateTargetGroup",
        "iam:DeleteRole",
        "ecs:DeleteService",
        "ecs:DeleteCluster",
        "logs:TagResource",
        "logs:CreateLogGroup",
        "logs:ListTagsForResource",
        "elasticloadbalancing:ModifyRule",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "iam:GetRolePolicy",
        "iam:UntagRole",
        "iam:TagRole",
        "iam:DeletePolicy",
        "ecs:DeregisterTaskDefinition",
        "elasticloadbalancing:RemoveTags",
        "elasticloadbalancing:CreateListener",
        "ecs:CreateService",
        "iam:DeleteRolePolicy",
        "iam:CreatePolicyVersion",
        "ecs:UntagResource",
        "ecs:List*",
        "elasticloadbalancing:DeleteRule",
        "elasticloadbalancing:CreateLoadBalancer",
        "logs:DescribeLogGroups",
        "logs:DeleteLogGroup",
        "ecs:Describe*",
        "logs:UntagResource",
        "elasticloadbalancing:SetSubnets",
        "elasticloadbalancing:DeleteTargetGroup",
        "iam:CreatePolicy",
        "elasticloadbalancing:SetSecurityGroups",
        "iam:UpdateRole",
        "logs:PutRetentionPolicy",
        "iam:DeletePolicyVersion",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:DeleteListener"
      ],
      "Resource": "*"
    },
    {
      "Sid": "VisualEditor1",
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": [
        "arn:aws:iam::<account-id>:role/*-ecs-task-execution-role",
        "arn:aws:iam::<account-id>:role/*-ecs-task-role"
      ],
      "Condition": {
        "StringEquals": {
          "iam:PassedToService": "ecs-tasks.amazonaws.com"
        }
      }
    },
    {
      "Sid": "VisualEditor2",
      "Effect": "Allow",
      "Action": [
        "s3:GetEncryptionConfiguration",
        "dynamodb:PutItem",
        "dynamodb:DescribeTable",
        "dynamodb:DeleteItem",
        "dynamodb:GetItem",
        "s3:ListBucket",
        "dynamodb:UpdateItem",
        "s3:GetBucketVersioning",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "arn:aws:s3:::<terraform-state-bucket-prefix>-*",
        "arn:aws:dynamodb:<region>:<account-id>:table/<terraform-lock-table-name>"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "sns:CreateTopic",
        "sns:DeleteTopic",
        "sns:GetTopicAttributes",
        "sns:SetTopicAttributes",
        "sns:TagResource",
        "sns:UntagResource",
        "sns:ListTagsForResource",
        "sns:Subscribe",
        "sns:Unsubscribe",
        "sns:GetSubscriptionAttributes",
        "sns:SetSubscriptionAttributes",
        "sns:ListSubscriptionsByTopic"
      ],
      "Resource": "arn:aws:sns:<region>:<account-id>:<alerts-topic-name>"
    },
    {
      "Sid": "VisualEditor3",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::<terraform-state-bucket-prefix>-*/*"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "elasticloadbalancing:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "cloudwatch:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "autoscaling:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "iam:CreateServiceLinkedRole",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "iam:AWSServiceName": [
            "autoscaling.amazonaws.com",
            "ec2scheduled.amazonaws.com",
            "elasticloadbalancing.amazonaws.com",
            "spot.amazonaws.com",
            "spotfleet.amazonaws.com",
            "transitgateway.amazonaws.com"
          ]
        }
      }
    }
  ]
}
```

## 4. Configure GitHub Repository Settings

After the role is created, add these repository settings:

### Secrets
- `AWS_ROLE_ARN`: ARN of the manually created GitHub Actions role
- `CONTAINER_IMAGE`: container image URI used by Terraform

### Variables
- `TF_BACKEND_BUCKET`: bootstrap S3 bucket name
- `TF_BACKEND_DYNAMODB_TABLE`: bootstrap DynamoDB table name
- `TF_BACKEND_REGION`: bootstrap region (for this repo, typically `us-east-1`)