terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "helm" {
  kubernetes = {
    host                   = module.aws_eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.aws_eks.cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks", "get-token",
        "--cluster-name", module.aws_eks.cluster_name
      ]
    }
  }
}

module "aws_vpc" {
  source = "../../../modules/aws/vpc"

  vpc_name               = var.vpc_name
  vpc_cidr               = var.vpc_cidr
  vpc_azs                = var.vpc_azs
  vpc_private_subnets    = var.vpc_private_subnets
  vpc_public_subnets     = var.vpc_public_subnets
  vpc_enable_nat_gateway = var.vpc_enable_nat_gateway
  vpc_single_nat_gateway = var.vpc_single_nat_gateway
  vpc_enable_vpn_gateway = var.vpc_enable_vpn_gateway
  vpc_terraform          = var.vpc_terraform
  vpc_environment        = var.vpc_environment
}

module "aws_s3" {
  source = "../../../modules/aws/s3"

  s3_bucket_name   = var.s3_bucket_name
  s3_force_destroy = var.s3_force_destroy
  s3_tags          = var.s3_tags
}

module "aws_eks" {
  source = "../../../modules/aws/eks"

  eks_name                                     = var.eks_name
  eks_kubernetes_version                       = var.eks_kubernetes_version
  eks_addons                                   = var.eks_addons
  eks_endpoint_public_access                   = var.eks_endpoint_public_access
  eks_enable_cluster_creator_admin_permissions = var.eks_enable_cluster_creator_admin_permissions
  eks_vpc_id                                   = module.aws_vpc.vpc_id
  eks_subnet_ids                               = module.aws_vpc.private_subnet_ids
  eks_managed_node_groups = {
    for name, node_group in var.eks_managed_node_groups :
    name => merge(node_group, {
      iam_role_additional_policies = merge(
        try(node_group.iam_role_additional_policies, {}),
        name == "worker" ? {
          s3_reports_write = module.aws_s3.worker_s3_policy_arn
        } : {}
      )
    })
  }
  eks_tags = var.eks_tags
}

module "aws_ecr" {
  source = "../../../modules/aws/ecr"

  ecr_repositories = var.ecr_repositories
  ecr_tags         = var.ecr_tags
}

resource "aws_security_group" "rds" {
  name        = "${var.rds_identifier}-sg"
  description = "Allow PostgreSQL access to ${var.rds_identifier} from within the VPC"
  vpc_id      = module.aws_vpc.vpc_id

  ingress {
    description     = "PostgreSQL access from within the VPC"
    from_port       = var.rds_port
    to_port         = var.rds_port
    protocol        = "tcp"
    security_groups = [module.aws_eks.node_security_group_id]
    # cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.rds_tags, {
    Name = "${var.rds_identifier}-sg"
  })
}

module "aws_rds" {
  source = "../../../modules/aws/rds"

  rds_identifier                          = var.rds_identifier
  rds_engine                              = var.rds_engine
  rds_engine_version                      = var.rds_engine_version
  rds_instance_class                      = var.rds_instance_class
  rds_allocated_storage                   = var.rds_allocated_storage
  rds_db_name                             = var.rds_db_name
  rds_username                            = var.rds_username
  rds_port                                = var.rds_port
  rds_iam_database_authentication_enabled = var.rds_iam_database_authentication_enabled
  rds_vpc_security_group_ids              = [aws_security_group.rds.id]
  rds_maintenance_window                  = var.rds_maintenance_window
  rds_backup_window                       = var.rds_backup_window
  rds_monitoring_interval                 = var.rds_monitoring_interval
  rds_monitoring_role_name                = var.rds_monitoring_role_name
  rds_create_monitoring_role              = var.rds_create_monitoring_role
  rds_tags                                = var.rds_tags
  rds_create_db_subnet_group              = var.rds_create_db_subnet_group
  rds_subnet_ids                          = module.aws_vpc.private_subnet_ids
  rds_family                              = var.rds_family
  rds_major_engine_version                = var.rds_major_engine_version
  rds_deletion_protection                 = var.rds_deletion_protection
  rds_parameters                          = var.rds_parameters
  rds_options                             = var.rds_options
}

module "aws_alb_controller_irsa" {
  source = "../../../modules/aws/alb"

  role_name                              = var.alb_controller_irsa_role_name
  oidc_provider_arn                      = module.aws_eks.oidc_provider_arn
  attach_load_balancer_controller_policy = var.alb_attach_load_balancer_controller_policy
  service_account_namespace              = var.alb_controller_service_account_namespace
  service_account_name                   = var.alb_controller_service_account_name
}

module "worker_irsa" {
  source = "../../../modules/aws/worker-irsa"

  role_name                 = var.worker_irsa_role_name
  oidc_provider_arn         = module.aws_eks.oidc_provider_arn
  service_account_namespace = var.worker_service_account_namespace
  service_account_name      = var.worker_service_account_name
  worker_s3_policy_arn      = module.aws_s3.worker_s3_policy_arn
  tags                      = var.eks_tags
}

module "aws_addons" {
  source = "../../../modules/aws/addons"

  cluster = {
    name   = module.aws_eks.cluster_name
    vpc_id = module.aws_vpc.vpc_id
  }

  alb_controller = {
    enabled              = true
    irsa_role_arn        = module.aws_alb_controller_irsa.iam_role_arn
    namespace            = var.alb_controller_service_account_namespace
    service_account_name = var.alb_controller_service_account_name
    wait                 = true
  }

  argocd = {
    enabled = true
  }

  prometheus_stack = {
    enabled = true
  }

  depends_on = [
    module.aws_alb_controller_irsa,
    module.aws_eks
  ]
}
