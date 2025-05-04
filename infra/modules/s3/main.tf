resource "aws_s3_bucket" "uploads" {
  bucket = "${var.environment}-uploads-${random_id.suffix.hex}"
  tags = {
    Environment = var.environment
    Name        = var.bucket_name
  }
  force_destroy = true
}
resource "random_id" "suffix" { byte_length = 4 }

resource "aws_s3_bucket_notification" "upload_notifications" {
  bucket = aws_s3_bucket.uploads.id

  lambda_function {
    lambda_function_arn = var.analyze_lambda_arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3_to_invoke_lambda]
}

resource "aws_lambda_permission" "allow_s3_to_invoke_lambda" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = var.analyze_lambda_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.uploads.arn
}
