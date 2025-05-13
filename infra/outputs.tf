output "cluster_endpoint"        { value = module.eks.cluster_endpoint }
output "uploads_bucket_name"     { value = module.s3.uploads_bucket_name }
output "kinesis_stream_name"     { value = module.kinesis.kinesis_stream_name }

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_id        // or module.eks.cluster_name depending on your module
}

output "eks_cluster_endpoint" {
  description = "EKS API endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_ca_data" {
  description = "Base64-encoded CA cert for the EKS cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = module.vpc.private_route_table_ids
}
output "db_password" {
  description = "TEMPORARY: RDS master password for debugging"
  value       = var.db_password
  sensitive   = true
}
output "db_username" {
  description = "TEMPORARY: RDS master username for debugging"
  value       = var.db_username
  sensitive   = true
}
