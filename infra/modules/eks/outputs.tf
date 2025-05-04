# output "cluster_endpoint" { value = module.eks.cluster_endpoint }
# output "cluster_certificate_authority_data" { value = module.eks.cluster_certificate_authority_data }
output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = module.eks.cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster certificate_authority_data"
  value       = module.eks.cluster_certificate_authority_data
}

output "oidc_provider_url" {
  value = module.eks.oidc_provider
}