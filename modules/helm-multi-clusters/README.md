# nOps AWS Compute Copilot Helm Installation Terraform Module

## Description
This module installs the nOps Compute Copilot on Multiples EKS cluster.

## Features
- Creation of a helm release to install the Compute Copilot service on Multiples EKS cluster

## Prerequisites

- Terraform v1.0+
- AWS CLI configured with appropriate permissions
- nOps API key

## Usage

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Module Usage

No modules.

```bash
provider "aws" {
  region = "us-west-2"
}

locals {
  clusters = {
    "nOps-dev2" = "us-west-2"
    # "nOps-uat"  = "us-west-2"
  }
}


module "helm_upgrade_install" {
  source = "nops-io/nops-compute-copilot-onboarding/aws//modules/helm-multi-clusters"

  for_each = local.clusters

  cluster_name    = each.key
  cluster_region  = each.value

  s3_bucket_name             = "nops-container-cost-account_id"
  nops_api_token             = ""
  datadog_api_key            = ""
  chart_version              = "latest"
  timeout                    = 300
  container_insights_enabled = true
  karpenops_enabled          = false
  karpenops_image_tag        = "1.23.6"
}
```
