data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

# HTTP Data Source to fetch the clusters
data "http" "clusters" {
  url = "https://app.nops.io/svc/karpenter_manager/clusters"

  request_headers = {
    Authorization = "Bearer ${var.nops_api_token}"
  }
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
        --set karpenops.clusterId=${var.karpenops_cluster_id} \
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


