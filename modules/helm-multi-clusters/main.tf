data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "http" "nops_clusters" {
  url = "https://app.nops.io/svc/karpenter_manager/clusters/?days=10"
  request_headers = {
    Accept         = "application/json"
    X-Nops-Api-Key = var.nops_api_token
  }
}

# Parse the API response
locals {
  clusters = jsondecode(data.http.nops_clusters.response_body)
  cluster  = [for c in local.clusters : c if c.name == var.cluster_name][0]

  # Basic platform detection
  is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true
}

# Install Helm chart
resource "null_resource" "helm_upgrade_install" {

  triggers = {
    cluster_name      = var.cluster_name
    cluster_region    = var.cluster_region
    kubeconfig        = "${path.module}/kubeconfig_${var.cluster_name}"
    helm_release_name = var.helm_release_name
    helm_namespace    = var.helm_namespace
    cluster_arn       = data.aws_eks_cluster.cluster.arn
    cluster_id        = local.cluster.external_id
    is_windows        = local.is_windows
  }

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${self.triggers.cluster_name} --region ${self.triggers.cluster_region} --kubeconfig ${self.triggers.kubeconfig}"
  }

  provisioner "local-exec" {
    command = "helm upgrade -i ${var.helm_release_name} ${var.helm_repo} --namespace ${var.helm_namespace} ${var.create_namespace ? "--create-namespace" : ""} --kubeconfig ${self.triggers.kubeconfig} --set datadog.apiKey=${var.datadog_api_key} --set containerInsights.enabled=${var.container_insights_enabled} --set containerInsights.env_variables.APP_NOPS_K8S_AGENT_CLUSTER_ARN=${self.triggers.cluster_arn} --set containerInsights.env_variables.APP_AWS_S3_BUCKET=${var.s3_bucket_name} --set karpenops.enabled=${var.karpenops_enabled} --set karpenops.image.tag=${var.karpenops_image_tag} --set karpenops.clusterId=${self.triggers.cluster_id} --set nops.apiKey=${var.nops_api_token}"
  }

  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : ["/bin/bash", "-c"]
    command = (
      local.is_windows
      ? "if (Test-Path ${self.triggers.kubeconfig}) { Remove-Item -Force ${self.triggers.kubeconfig} }"
      : "rm -f ${self.triggers.kubeconfig}"
    )
  }

  # Uninstall Helm chart
  provisioner "local-exec" {
    when    = destroy
    command = "aws eks update-kubeconfig --name ${self.triggers.cluster_name} --region ${self.triggers.cluster_region} --kubeconfig ${self.triggers.kubeconfig}"
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "helm uninstall ${self.triggers.helm_release_name} --namespace ${self.triggers.helm_namespace} --kubeconfig ${self.triggers.kubeconfig}"
    on_failure = continue
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = self.triggers.is_windows ? ["PowerShell", "-Command"] : ["/bin/bash", "-c"]
    command = (
      self.triggers.is_windows
      ? "if (Test-Path ${self.triggers.kubeconfig}) { Remove-Item -Force ${self.triggers.kubeconfig} }"
      : "rm -f ${self.triggers.kubeconfig}"
    )
    on_failure = continue
  }
}
