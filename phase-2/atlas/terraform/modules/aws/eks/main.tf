module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.eks_name
  kubernetes_version = var.eks_kubernetes_version

  addons = var.eks_addons

  # Optional
  endpoint_public_access = var.eks_endpoint_public_access

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = var.eks_enable_cluster_creator_admin_permissions

  vpc_id     = var.eks_vpc_id
  subnet_ids = var.eks_subnet_ids

  # EKS Managed Node Group(s)
  eks_managed_node_groups = var.eks_managed_node_groups

  tags = var.eks_tags
}
