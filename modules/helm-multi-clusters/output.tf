# Output the full response body from the HTTP data source
output "clusters_response_body" {
  value = data.http.clusters.response_body
}
