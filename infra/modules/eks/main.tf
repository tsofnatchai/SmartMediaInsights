# module "eks" {
#   source          = "terraform-aws-modules/eks/aws"
#   cluster_name    = "${var.environment}-cluster"
#   cluster_version = "1.24"
#   subnets         = var.private_subnets
#   vpc_id          = var.vpc_id
#
#   node_groups = {
#     default = {
#       desired_capacity = 2
#       max_capacity     = 3
#       min_capacity     = 1
#       instance_type    = "t3.medium"
#     }
#   }
# }
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "19.16.0"  # Latest stable version
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  subnet_ids      = var.private_subnets
  vpc_id          = var.vpc_id

  eks_managed_node_groups = {
    eks_nodes = {
      desired_capacity = var.desired_capacity
      max_size         = var.max_size
      min_size         = var.min_size

      instance_types = ["t3.medium"]

      labels = {
        Environment = "dev"
      }
    }
  }

  cluster_endpoint_public_access = true
  tags = {
    Name = "eks-cluster"
  }
}
