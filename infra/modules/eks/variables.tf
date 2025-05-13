variable "vpc_id" {
  description = "VPC ID for EKS cluster"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  default     = "my-eks-cluster-smart"
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  default     = 2
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  default     = 3
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  default     = 1
}

variable "instance_type" {
  description = "EC2 instance type for the worker nodes"
  default     = "t3.medium"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}