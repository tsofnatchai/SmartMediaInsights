
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"
  name = "my-vpc"
  cidr = var.vpc_cidr

  # Define AZs using region + suffixes
  azs             = [ "${var.region}a", "${var.region}b" ]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_support   = true      # Enables DNS resolution in the VPC
  enable_dns_hostnames = true      # Enables DNS hostnames (required for public services like RDS)

  public_subnet_tags  = { Tier = "public" }
  private_subnet_tags = { Tier = "private" }
}

