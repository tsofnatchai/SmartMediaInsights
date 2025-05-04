variable "environment" { type = string }
variable "lambda_role_arn" { type = string }
variable "db_host" { type = string }
variable "db_user" { type = string }
variable "db_password" { type = string }
variable "db_name" { type = string }

variable "kinesis_stream_arn" {
  type = string
}
variable "private_subnets" {
  description = "Private subnets for Lambda VPC config"
  type        = list(string)
}

variable "lambda_security_group_id" {
  description = "Security group ID for Lambda function"
  type        = string
}
