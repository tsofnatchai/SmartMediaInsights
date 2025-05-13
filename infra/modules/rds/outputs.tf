output "rds_endpoint" {
  description = "Endpoint of the RDS MySQL instance"
  value       = module.rds_mysql.db_instance_endpoint
}

output "rds_resource_id" {
  description = "Resource ID of the RDS instance"
  value       = module.rds_mysql.db_instance_resource_id
}
