# resource "aws_iam_role" "eks_node" {
#   name = "${var.environment}-eks-node-role"
#   assume_role_policy = data.aws_iam_policy_document.eks_assume.role_policy
# }
# ... define policies and instance profile for EKS nodes, Lambda, Terraform, CI

# resource "aws_iam_role" "eks_node" {
#   name = "${var.environment}-eks-node-role"
#
#   assume_role_policy = jsonencode({
#     Version   = "2012-10-17",
#     Statement = [{
#       Effect    = "Allow",
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       },
#       Action    = "sts:AssumeRole"
#     }]
#   })
# }
#
# resource "aws_iam_policy" "ec2_policy" {
#   name        = var.ec2_policy_name
#   description = "Allows EC2 instances to read from S3 buckets"
#
#   policy = jsonencode({
#     Version   = "2012-10-17",
#     Statement = [{
#       Effect   = "Allow",
#       Action   = [
#         "s3:GetObject",
#         "s3:ListBucket",
#         "s3:PutObject"
#       ],
#       Resource = [
#         var.s3_bucket_arn,
#         "${var.s3_bucket_arn}/*"
#       ]
#     }]
#   })
# }
#
# resource "aws_iam_role_policy_attachment" "ec2_policy_attachment" {
#   role       = aws_iam_role.eks_node.name
#   policy_arn = aws_iam_policy.ec2_policy.arn
# }

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
        "arn:aws:s3:::dev-uploads-d4834098",
        "arn:aws:s3:::dev-uploads-d4834098/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "upload_service_policy_attach" {
  role       = aws_iam_role.upload_service_role.name
  policy_arn = aws_iam_policy.upload_service_s3_policy.arn
}
