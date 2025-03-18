module "wrapper" {
  source = "../../modules/helm-multi-clusters"

  for_each = var.items

  cluster_name               = try(each.value.cluster_name, var.defaults.cluster_name)
  cluster_region             = try(each.value.cluster_region, var.defaults.cluster_region)
  container_insights_enabled = try(each.value.container_insights_enabled, var.defaults.container_insights_enabled, true)
  create_namespace           = try(each.value.create_namespace, var.defaults.create_namespace, true)
  datadog_api_key            = try(each.value.datadog_api_key, var.defaults.datadog_api_key)
  helm_namespace             = try(each.value.helm_namespace, var.defaults.helm_namespace, "nops")
  helm_release_name          = try(each.value.helm_release_name, var.defaults.helm_release_name, "nops-kubernetes-agent")
  helm_repo                  = try(each.value.helm_repo, var.defaults.helm_repo, "oci://public.ecr.aws/nops/kubernetes-agent")
  karpenops_enabled          = try(each.value.karpenops_enabled, var.defaults.karpenops_enabled, true)
  karpenops_image_tag        = try(each.value.karpenops_image_tag, var.defaults.karpenops_image_tag, "1.23.7")
  nops_api_token             = try(each.value.nops_api_token, var.defaults.nops_api_token)
  s3_bucket_name             = try(each.value.s3_bucket_name, var.defaults.s3_bucket_name, "")
}
