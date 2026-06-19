# Local Terraform Sandbox

Infrastructure-as-code lab for the NiteOpsTech / NanoMesh roadmap.

## Purpose

This repo defines a small AWS sandbox for security lab experiments. It is
intended to be **plan-first** and least-privilege friendly.

## Safety Defaults

- Uses the named AWS CLI profile `niteops-lab`.
- Does not store AWS credentials in Terraform files.
- Does not create inbound SSH access by default.
- Does not assign a public IP to the EC2 instance by default.
- Ignores Terraform state and local variable files.

## Prerequisites

Configure AWS CLI with a named profile:

```powershell
aws configure --profile niteops-lab
```

Verify identity:

```powershell
aws sts get-caller-identity --profile niteops-lab
```

## Validate Locally

```powershell
terraform fmt
terraform init
terraform validate
```

## Plan Only

Start with a plan. Do not apply until the IAM policy is intentionally scoped for
resource creation and you have reviewed cost impact.

```powershell
$env:AWS_PROFILE="niteops-lab"
terraform plan
```

Optional SSH access requires your trusted public IP CIDR:

```powershell
terraform plan -var="allowed_ssh_cidr=x.x.x.x/32"
```

## NanoMesh Role

This repo is the cloud sandbox layer:

```text
Terraform VPC/subnet/security group
-> controlled lab host
-> telemetry experiments
-> detection/SOAR/matrix validation
```

## Cost Guardrail

Before `terraform apply`, create a billing alert in AWS Budgets and review all
resources in the plan output.
