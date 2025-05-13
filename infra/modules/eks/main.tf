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
