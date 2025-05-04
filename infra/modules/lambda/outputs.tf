output "analyze_image_arn" { value = aws_lambda_function.analyze_image.arn }
output "analyze_image_name" {
  value = aws_lambda_function.analyze_image.function_name
}
