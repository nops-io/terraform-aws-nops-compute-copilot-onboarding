resource "nops_compute_copilot_integration" "integration" {
  cluster_arns = local.target_clusters_arns
  region_name  = data.aws_region.current.id
  version      = local.module_version
  account_id   = local.current_nops_project[0].id
}

resource "nops_container_cost_bucket" "container_cost_bucket" {
  project_id = local.current_nops_project[0].id
}
