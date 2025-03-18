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
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 3.4.5 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.2.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_http"></a> [http](#provider\_http) | ~> 3.4.5 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [null_resource.helm_upgrade_install](https://registry.terraform.io/providers/hashicorp/null/3.2.3/docs/resources/resource) | resource |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [http_http.nops_clusters](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the EKS cluster. | `string` | n/a | yes |
| <a name="input_cluster_region"></a> [cluster\_region](#input\_cluster\_region) | The AWS region where the EKS cluster is located. | `string` | n/a | yes |
| <a name="input_container_insights_enabled"></a> [container\_insights\_enabled](#input\_container\_insights\_enabled) | Whether to enable container insights. | `bool` | `true` | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Whether to create the namespace if it doesn't exist. | `bool` | `true` | no |
| <a name="input_datadog_api_key"></a> [datadog\_api\_key](#input\_datadog\_api\_key) | The Datadog API key. | `string` | n/a | yes |
| <a name="input_helm_namespace"></a> [helm\_namespace](#input\_helm\_namespace) | The Kubernetes namespace where the Helm chart will be installed. | `string` | `"nops"` | no |
| <a name="input_helm_release_name"></a> [helm\_release\_name](#input\_helm\_release\_name) | The name of the Helm release. | `string` | `"nops-kubernetes-agent"` | no |
| <a name="input_helm_repo"></a> [helm\_repo](#input\_helm\_repo) | The Helm chart repository URL. | `string` | `"oci://public.ecr.aws/nops/kubernetes-agent"` | no |
| <a name="input_karpenops_enabled"></a> [karpenops\_enabled](#input\_karpenops\_enabled) | Whether to enable Karpenops. | `bool` | `true` | no |
| <a name="input_karpenops_image_tag"></a> [karpenops\_image\_tag](#input\_karpenops\_image\_tag) | The image tag for Karpenops. | `string` | `"1.23.7"` | no |
| <a name="input_nops_api_token"></a> [nops\_api\_token](#input\_nops\_api\_token) | API token to authenticate with the nOps platform. | `string` | n/a | yes |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | S3 bucket for Container Cost exports, useful if bucket is in another region. | `string` | `""` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
