
variable "nops_api_token" {
  type        = string
  description = "API token to authenticate with the nOps platform."
}

variable "chart_version" {
  type        = string
  description = "Compute Copilot chart version to install."
  default     = ""
}

variable "timeout" {
  type        = number
  description = "Timeout to be set for chart installation."
  default     = 300
}

variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster."
}

variable "cluster_region" {
  type        = string
  description = "The AWS region where the EKS cluster is located."
}

variable "helm_release_name" {
  type        = string
  description = "The name of the Helm release."
  default     = "nops-kubernetes-agent"
}

variable "helm_repo" {
  type        = string
  description = "The Helm chart repository URL."
  default     = "oci://public.ecr.aws/nops/kubernetes-agent"
}

variable "helm_namespace" {
  type        = string
  description = "The Kubernetes namespace where the Helm chart will be installed."
  default     = "nops"
}

variable "create_namespace" {
  type        = bool
  description = "Whether to create the namespace if it doesn't exist."
  default     = true
}

variable "datadog_api_key" {
  type        = string
  description = "The Datadog API key."
  sensitive   = true
}

variable "container_insights_enabled" {
  type        = bool
  description = "Whether to enable container insights."
  default     = true
}

variable "karpenops_enabled" {
  type        = bool
  description = "Whether to enable Karpenops."
  default     = true
}

variable "karpenops_image_tag" {
  type        = string
  description = "The image tag for Karpenops."
  default     = "1.23.7"
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket for Container Cost exports, useful if bucket is in another region."
  default     = ""
}
