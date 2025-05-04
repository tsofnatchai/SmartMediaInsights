output "cluster_endpoint"        { value = module.eks.cluster_endpoint }
output "uploads_bucket_name"     { value = module.s3.uploads_bucket_name }
output "kinesis_stream_name"     { value = module.kinesis.kinesis_stream_name }


// infra/outputs.tf

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
# output "nat_gateway_ids" {
#   description = "NAT Gateway IDs from VPC module"
#   value       = module.vpc.public_nat_gateway_ids
# }


output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = module.vpc.private_route_table_ids
}
