# ECS Fargate Platform

A modular Terraform project that deploys a private ECS Fargate service behind a public Application Load Balancer (ALB) in AWS.

This project is built to show practical cloud infrastructure patterns: private container workloads, reusable Terraform modules, remote state management, and GitHub Actions-based CI/CD.

---

## Overview

The platform runs containerized workloads on ECS Fargate in private subnets with no public IPs. All inbound traffic flows through a public ALB, and security group rules ensure only the ALB can reach the ECS service.

The repository is currently scoped to a single `dev` environment, but the structure is designed to support additional environments later.

---

## Architecture

**Core design**

* VPC across 2 Availability Zones
* Public subnets for the ALB and NAT Gateways
* Private subnets for ECS tasks
* Internet-facing ALB forwarding traffic to ECS
* Security group chaining between ALB and ECS
* S3 remote state backend with DynamoDB locking

**Traffic flow**

1. Client sends HTTP traffic to the ALB
2. ALB forwards traffic to the ECS target group
3. ECS tasks run in private subnets and only accept traffic from the ALB security group
4. Tasks use NAT Gateways for outbound internet access when needed

---

## Features

### Infrastructure

* VPC with public and private subnets across 2 AZs
* Internet Gateway and per-AZ NAT Gateways
* Public ALB with target group health checks
* ECS Fargate service running in private subnets
* Security group chaining between ALB and ECS

### Terraform

* Reusable modules for:

  * `network`
  * `alb`
  * `ecs_service`
* Separate bootstrap configuration for backend resources
* S3 remote state bucket with versioning, encryption, and public access block
* DynamoDB table for state locking

### CI/CD

* GitHub Actions CI workflow for:

  * `terraform fmt -check`
  * `terraform validate`
  * `terraform plan`
* GitHub Actions CD workflow for:

  * `terraform fmt -check`
  * `terraform validate`
  * `terraform plan -out=tfplan`
  * `terraform apply tfplan`
* AWS authentication through GitHub OIDC role assumption

### Reliability and Observability

* ECS deployment circuit breaker with rollback enabled
* ECS Container Insights enabled on the cluster
* CloudWatch log group for ECS task logs
* CloudWatch alarm for ALB unhealthy targets
* SNS email notifications for alarm state changes

---

## Repository Structure

```text
.
├── .github/
│   └── workflows/
│       ├── terraform-ci.yml
│       └── terraform-cd.yml
├── infra/
│   ├── bootstrap/
│   ├── envs/
│   │   └── dev/
│   └── modules/
│       ├── network/
│       ├── alb/
│       └── ecs_service/
└── README.md
```

---

## Prerequisites

Before deploying, make sure you have:

* Terraform installed
* An AWS account and credentials with permission to create the required resources
* A container image URI for the ECS task



---

## Deployment

### 1. Bootstrap the backend

The backend infrastructure is managed separately and must be created first.

This step provisions:

* S3 bucket for Terraform state
* DynamoDB table for state locking

```bash
cd infra/bootstrap
terraform init
terraform apply
```

If you are using the example backend config file, copy the bootstrap outputs into `infra/envs/dev/backend.tfbackend`.

### 2. Deploy the dev environment

```bash
cd infra/envs/dev
terraform init -backend-config=backend.tfbackend
terraform plan
terraform apply
```

After deployment, get the public endpoint with:

```bash
terraform output alb_dns_name
```

---

## Configuration

### Committed configuration

`terraform.tfvars` stores normal non-sensitive environment settings such as:

* region
* project name
* environment
* VPC CIDR
* container port
* desired count

### Local-only configuration

`local.auto.tfvars` is for local values that should not be committed, such as:

```hcl
alarm_email = "you@example.com"
```

### Required runtime input

The ECS service requires a container image. Supply it through your environment-specific Terraform variables or local override file.

---

## GitHub Actions Setup

The CI/CD workflows require the following GitHub repository settings.

### Repository Secrets
- `AWS_ROLE_ARN`
- `CONTAINER_IMAGE`

### Repository Variables
- `TF_BACKEND_BUCKET`
- `TF_BACKEND_DYNAMODB_TABLE`
- `TF_BACKEND_REGION`

The workflows use GitHub OIDC to assume the AWS role, and `CONTAINER_IMAGE` is passed to Terraform as `TF_VAR_container_image` during the plan step.

---

## CI/CD Workflows

### Terraform CI

Triggered on pull requests that modify `infra/**`.

Runs:

* format check
* validate
* plan

### Terraform CD

Triggered on pushes to `main` that modify `infra/**`.

Runs:

* format check
* validate
* plan to a saved plan file
* apply saved plan

Both workflows authenticate to AWS using GitHub OIDC.

---

## Monitoring and Reliability

### Health checks

The ALB target group performs HTTP health checks against:

* path: `/health`
* matcher: `200`

### Deployment safety

The ECS service uses a deployment circuit breaker with automatic rollback if a deployment fails to reach a healthy state.

### Monitoring

* ECS Container Insights is enabled
* ECS task logs are sent to CloudWatch Logs
* A CloudWatch alarm monitors `UnHealthyHostCount`
* SNS sends email notifications for alarm transitions

---

## IAM Roles

This project creates two ECS-related IAM roles.

### Task execution role

Used by ECS/Fargate to:

* pull container images from ECR
* write logs to CloudWatch Logs

This role uses the AWS-managed `AmazonECSTaskExecutionRolePolicy`.

### Task role

Used by the application container if it needs to call AWS APIs.

It is currently created without attached permissions, which leaves a clean extension point for future app-specific access.

---

## Useful Outputs

Common outputs include:

* `alb_dns_name`
* `alb_arn`
* `alb_target_group_arn`
* `alb_security_group_id`
* `ecs_service_security_group_id`
* `ecs_task_execution_role_arn`
* `ecs_task_role_arn`
* `ecs_task_log_group_name`
* `vpc_id`
* `public_subnet_ids`
* `private_subnet_ids`

---

## Current Scope

This project is intentionally scoped as a `dev` platform. It demonstrates:

* modular Terraform design
* secure private container placement
* remote state management
* CI/CD workflow integration
* reliability and observability fundamentals

---

## Possible Next Steps

* HTTPS listener with ACM certificate
* HTTP to HTTPS redirect
* ECS service auto scaling
* ALB access logging
* WAF integration
* staging and production environments
* application-specific IAM policies for the task role
* image build and push pipeline
