resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = <<-EOT
      aws eks update-kubeconfig \
        --name ${var.cluster_name} \
        --region ${var.cluster_region} \
        --kubeconfig ${path.module}/kubeconfig_${var.cluster_name}
    EOT
  }
}

resource "null_resource" "helm_upgrade_install" {
  depends_on = [null_resource.update_kubeconfig]

  triggers = {
    cluster_name      = var.cluster_name
    kubeconfig        = "${path.module}/kubeconfig_${var.cluster_name}"
    helm_release_name = var.helm_release_name
    helm_namespace    = var.helm_namespace
  }

  provisioner "local-exec" {
    command = <<-EOT
      helm upgrade -i ${var.helm_release_name} ${var.helm_repo} \
        --namespace ${var.helm_namespace} \
        ${var.create_namespace ? "--create-namespace" : ""} \
        --kubeconfig ${self.triggers.kubeconfig} \
        --set datadog.apiKey=${var.datadog_api_key} \
        --set containerInsights.enabled=${var.container_insights_enabled} \
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