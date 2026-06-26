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

module "aws_vpc" {
  source = "../../modules/vpc"

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

module "aws_eks" {
  source = "../../modules/eks"

  eks_name                                     = var.eks_name
  eks_kubernetes_version                       = var.eks_kubernetes_version
  eks_addons                                   = var.eks_addons
  eks_endpoint_public_access                   = var.eks_endpoint_public_access
  eks_enable_cluster_creator_admin_permissions = var.eks_enable_cluster_creator_admin_permissions
  eks_vpc_id                                   = module.aws_vpc.vpc_id
  eks_subnet_ids                               = module.aws_vpc.private_subnet_ids
  eks_managed_node_groups                      = var.eks_managed_node_groups
  eks_tags                                     = var.eks_tags
}

resource "aws_security_group" "rds" {
  name        = "${var.rds_identifier}-sg"
  description = "Allow PostgreSQL access to ${var.rds_identifier} from within the VPC"
  vpc_id      = module.aws_vpc.vpc_id

  ingress {
    description = "PostgreSQL access from within the VPC"
    from_port   = var.rds_port
    to_port     = var.rds_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
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
  source = "../../modules/rds"

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
