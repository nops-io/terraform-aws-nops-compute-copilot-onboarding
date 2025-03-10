data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "http" "nops_clusters" {
  url = "https://app.nops.io/svc/karpenter_manager/clusters/?days=10"
  request_headers = {
    Accept        = "application/json"
    X-Nops-Api-Key = var.nops_api_token
  }
}

# Parse the API response
locals {
  clusters = jsondecode(data.http.nops_clusters.response_body)
  cluster  = [for c in local.clusters : c if c.name == var.cluster_name][0]
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
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws eks update-kubeconfig \
        --name ${self.triggers.cluster_name} \
        --region ${self.triggers.cluster_region} \
        --kubeconfig ${self.triggers.kubeconfig}
    EOT
  }

  provisioner "local-exec" {
    command = <<-EOT
      helm upgrade -i ${var.helm_release_name} ${var.helm_repo} \
        --namespace ${var.helm_namespace} \
        ${var.create_namespace ? "--create-namespace" : ""} \
        --kubeconfig ${self.triggers.kubeconfig} \
        --set datadog.apiKey=${var.datadog_api_key} \
        --set containerInsights.enabled=${var.container_insights_enabled} \
        --set containerInsights.env_variables.APP_NOPS_K8S_AGENT_CLUSTER_ARN=${self.triggers.cluster_arn} \
        --set containerInsights.env_variables.APP_AWS_S3_BUCKET=${var.s3_bucket_name} \
        --set karpenops.enabled=${var.karpenops_enabled} \
        --set karpenops.image.tag=${var.karpenops_image_tag} \
        --set karpenops.clusterId=${self.triggers.cluster_id} \
        --set nops.apiKey=${var.nops_api_token}
    EOT
  }

  provisioner "local-exec" {
    command = <<-EOT
      rm -f ${self.triggers.kubeconfig}
    EOT
  }


  # Uninstall Helm chart
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      aws eks update-kubeconfig \
        --name ${self.triggers.cluster_name} \
        --region ${self.triggers.cluster_region} \
        --kubeconfig ${self.triggers.kubeconfig}
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      helm uninstall ${self.triggers.helm_release_name} --namespace ${self.triggers.helm_namespace} --kubeconfig ${self.triggers.kubeconfig}
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      rm -f ${self.triggers.kubeconfig}
    EOT
  }
}


