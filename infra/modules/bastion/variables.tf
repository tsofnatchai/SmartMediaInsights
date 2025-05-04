variable "environment" {
  description = "Deployment environment"
  type        = string
}
variable "vpc_id" {
  description = "The VPC where bastion will be deployed"
  type        = string
}
variable "public_subnets" {
  description = "List of public subnet IDs for bastion host"
  type        = list(string)
}
variable "bastion_key_pair" {
  description = "Name of the SSH key pair for bastion host"
  type        = string
}
variable "bastion_public_key_path" {
  description = "Path to the public key file for bastion key pair"
  type        = string
}
variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into bastion"
  type        = string
}
variable "bastion_ami" {
  description = "AMI ID for the bastion host"
  type        = string
}
variable "bastion_instance_type" {
  description = "EC2 instance type for bastion host"
  type        = string
}