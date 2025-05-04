output "uploads_bucket_name" { value = aws_s3_bucket.uploads.bucket }
output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket for Kinesis delivery"
  value       = aws_s3_bucket.uploads.arn
}
