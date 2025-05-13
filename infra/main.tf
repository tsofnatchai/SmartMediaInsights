
#################################################################
# VPC + Networking
#################################################################
module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr   = var.vpc_cidr
  region   = var.region
}

#################################################################
# Bastion Jump-Host
#################################################################
module "bastion" {
  source                  = "./modules/bastion"
  environment             = var.environment
  vpc_id                  = module.vpc.vpc_id
  public_subnets          = module.vpc.public_subnets
  bastion_key_pair        = var.bastion_key_pair
  bastion_public_key_path = var.bastion_public_key_path
  ssh_allowed_cidr        = var.ssh_allowed_cidr
  bastion_ami             = var.bastion_ami
  bastion_instance_type   = var.bastion_instance_type
}

#################################################################
# IAM & Roles
#################################################################
module "iam_upload_service" {
  source                = "./modules/iam"
  environment           = var.environment
  ec2_policy_name       = var.ec2_policy_name
  instance_profile_name = var.instance_profile_name
  oidc_provider_url    = module.eks.oidc_provider_url
  s3_bucket_arn         = module.s3.s3_bucket_arn
  namespace            = "production"
  region                 = var.region
  service_account_name = "upload-service-sa"
  kinesis_stream_name    = module.kinesis.kinesis_stream_name
}

#################################################################
# KMS Customer-Managed Key
#################################################################
module "kms" {
  source      = "./modules/kms"
}

#################################################################
# EKS Cluster + Node Groups
#################################################################
module "eks" {
  source          = "./modules/eks"
  cluster_name   = var.cluster_name
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  cluster_version= var.cluster_version
}
module "security" {
  source      = "./modules/security"
  vpc_id      = module.vpc.vpc_id
  alb_sg_cidr = var.alb_sg_cidr
  environment = var.environment
  bastion_sg_id = module.bastion.bastion_security_group_id
}
#################################################################
# Databases
#################################################################

module "rds" {
  source                 = "./modules/rds"
  vpc_id                 = module.vpc.vpc_id
  public_subnets         = module.vpc.public_subnets
  ec2_security_group_id  = module.security.rds_security_group_id
  db_name                = var.db_name
  db_username            = var.db_username
  db_password            = var.db_password
}


module "dynamodb" {
  source      = "./modules/dynamodb"
  environment = var.environment
}

#################################################################
# Storage & Streaming
#################################################################
module "s3" {
  source      = "./modules/s3"
  environment = var.environment
  bucket_name = var.s3_bucket_name
  analyze_lambda_arn = module.lambda.analyze_image_arn
  analyze_lambda_name = module.lambda.analyze_image_name
}

module "kinesis" {
  source      = "./modules/kinesis"
  environment = var.environment
}

#################################################################
# Serverless Lambdas
#################################################################

module "lambda" {
  source = "./modules/lambda"
  environment         = var.environment
  lambda_role_arn = module.iam_upload_service.eks_node_role_arn
  db_host     = module.rds.rds_endpoint#"mysql-db.curs4g4yygzv.us-east-1.rds.amazonaws.com"
  db_user     = var.db_username
  db_password = var.db_password
  db_name     = var.db_name
  kinesis_stream_arn  = module.kinesis.kinesis_stream_arn
  private_subnets         = module.vpc.private_subnets
  lambda_security_group_id = module.security.lambda_security_group_id
}

#################################################################
# WAF Web ACL
#################################################################
module "waf" {
  source      = "./modules/waf"
  environment = var.environment
}

