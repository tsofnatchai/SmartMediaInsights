
resource "aws_iam_instance_profile" "ec2_profile" {
  name = var.instance_profile_name
  role = aws_iam_role.upload_service_role.name
}
data "aws_caller_identity" "current" {}
resource "aws_iam_role" "upload_service_role" {
  name = "upload-service-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider_url}"
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${var.oidc_provider_url}:sub" = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "upload_service_s3_policy" {
  name = "upload-service-s3-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
      ],
      Resource = [
        "${var.s3_bucket_arn}",
        "${var.s3_bucket_arn}/*"
      ]
    }]
  })
}


resource "aws_iam_role_policy_attachment" "upload_service_policy_attach" {
  role       = aws_iam_role.upload_service_role.name
  policy_arn = aws_iam_policy.upload_service_s3_policy.arn
}
resource "aws_iam_policy" "analyze_image_lambda_s3_policy" {
  name = "analyze-image-lambda-s3-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ],
        Resource = [
          "${var.s3_bucket_arn}",
          "${var.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "analyze_image_lambda_policy_attach" {
  role       = "dev-lambda-exec-role" # replace with actual role name or data source
  policy_arn = aws_iam_policy.analyze_image_lambda_s3_policy.arn
}

resource "aws_iam_policy" "analyze_image_lambda_kinesis_policy" {
  name = "analyze-image-lambda-kinesis-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kinesis:PutRecord",
          "kinesis:PutRecords"
        ],
        Resource = "arn:aws:kinesis:${var.region}:${data.aws_caller_identity.current.account_id}:stream/${var.kinesis_stream_name}"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "analyze_image_lambda_kinesis_policy_attach" {
  role       = "dev-lambda-exec-role" # This can be a hardcoded string or a data source if you're importing it
  policy_arn = aws_iam_policy.analyze_image_lambda_kinesis_policy.arn
}

