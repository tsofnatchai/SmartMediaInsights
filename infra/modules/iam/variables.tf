variable "environment" { type = string }

variable "ec2_policy_name" {
  description = "The name for the IAM policy to grant EC2 S3 read access."
  type        = string
}

variable "instance_profile_name" {
  description = "The name for the IAM instance profile."
  type        = string
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket that EC2 instances need to access."
  type        = string
}
variable "oidc_provider_url" {
  description = "OIDC provider URL for EKS IRSA"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace where the pod runs"
  type        = string
  default     = "production"
}

variable "service_account_name" {
  description = "Kubernetes ServiceAccount name"
  type        = string
  default     = "upload-service-sa"
}
variable "region" {
  description = "AWS region"
  type        = string
}

variable "kinesis_stream_name" {
  description = "Kinesis stream name"
  type        = string
}
