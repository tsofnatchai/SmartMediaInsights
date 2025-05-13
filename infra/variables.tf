
variable "db_name" {
  description = "RDS database name"
  type        = string
  default     = "mydatabase"
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
  default     = "ChangeMe123!"
}

# IAM module parameters
variable "ec2_policy_name" {
  description = "Name for the custom EC2 S3-read IAM policy"
  type        = string
  default = "example-ec2-policy"
}

variable "instance_profile_name" {
  description = "Name for the EC2 instance profile for EKS worker nodes"
  type        = string
  default = "example-instance-profile"
}
variable "region" {
type    = string
default = "us-east-1"
}

variable "environment" {
type    = string
default = "dev"
}

# Bastion host configuration
variable "bastion_key_pair" {
description = "SSH key pair name for the bastion host"
type        = string
default = "my-bastion-key"
}

variable "bastion_public_key_path" {
description = "Filesystem path to the SSH public key for the bastion key pair"
type        = string
default = "~/.ssh/id_rsa.pub"
}

variable "ssh_allowed_cidr" {
description = "CIDR range allowed to SSH into the bastion host"
type        = string
default = "203.0.113.4/32"
}

variable "bastion_ami" {
  description = "AMI ID to use for the bastion host"
  type        = string
  default     = "ami-049682606efa7fe65"  # Example: Amazon Linux 2 in us-east-1
}

variable "bastion_instance_type" {
description = "EC2 instance type for the bastion host"
type        = string
default     = "t3.micro"
}
variable "s3_bucket_name" {
  description = "Name of the S3 bucket used by the application (e.g. uploads, logs, etc.)"
  type        = string
}
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "my-eks-cluster-smart"
}
variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.31"#"1.24"
}
variable "alb_sg_cidr" {
  description = "CIDR block allowed to access the ALB"
  type        = string
  default     = "0.0.0.0/0"
}
variable "publicly_accessible" {
  description = "RDS publicly_accessible"
  type        = bool
  default     = true
}