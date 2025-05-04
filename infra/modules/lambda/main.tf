resource "aws_lambda_function" "analyze_image" {
  filename         = "${path.module}/analyze_image.zip"
  function_name    = "${var.environment}-analyze-image"
  handler          = "handler.lambda_handler"
  runtime          = "python3.8"
  #role             = var.lambda_role_arn
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256("${path.module}/analyze_image.zip")
}
resource "aws_iam_role" "lambda_exec" {
  name = "${var.environment}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_lambda_function" "process_stream" {
  filename         = "${path.module}/process_stream.zip"
  function_name    = "${var.environment}-process-stream"
  handler          = "handler.lambda_handler"
  runtime          = "python3.8"
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256("${path.module}/process_stream.zip")
  timeout          = 15

  environment {
    variables = {
      DB_HOST     = var.db_host
      DB_USER     = var.db_user
      DB_PASSWORD = var.db_password
      DB_NAME     = var.db_name
    }
  }
  vpc_config {
    subnet_ids         = var.private_subnets       # the same subnets used for RDS
    security_group_ids = [var.lambda_security_group_id]  # allow outbound to RDS port 3306
  }
}
resource "aws_lambda_event_source_mapping" "kinesis_to_process_stream" {
  event_source_arn  = var.kinesis_stream_arn
  function_name     = aws_lambda_function.process_stream.arn
  starting_position = "LATEST"
  batch_size        = 1
  enabled           = true
}
resource "aws_iam_role_policy_attachment" "lambda_kinesis_access" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisReadOnlyAccess"
}
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda_vpc_network" {
  name = "lambda-vpc-network"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        Resource = "*"
      }
    ]
  })
}
