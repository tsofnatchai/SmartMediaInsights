output "eks_node_role_arn" {
  description = "The ARN of the created EKS IAM role."
  value       = aws_iam_role.upload_service_role.arn
}

output "instance_profile_name" {
  description = "The name of the IAM instance profile."
  value       = aws_iam_instance_profile.ec2_profile.name
}
output "upload_service_role_arn" {
  value = aws_iam_role.upload_service_role.arn
}

