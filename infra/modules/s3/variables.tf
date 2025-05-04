variable "environment" {
  description = "Environment tag for the bucket"
  type        = string
  default     = "dev"
}

variable "bucket_name" {
  description = "Name of the S3 bucket for Kinesis Firehose delivery"
  type        = string
}
variable "analyze_lambda_arn" {
  description = "ARN of the analyze_image Lambda function"
  type        = string
}
variable "analyze_lambda_name" {
  type        = string
  description = "Name of the analyze_image lambda"
}

