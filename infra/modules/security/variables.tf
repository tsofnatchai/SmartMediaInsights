variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "alb_sg_cidr" {
  description = "CIDR block allowed to access the ALB"
  type        = string
}
variable "environment" { type = string }