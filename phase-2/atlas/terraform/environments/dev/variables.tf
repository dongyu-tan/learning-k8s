variable "aws_region" {
  type        = string
  description = "AWS Region to deploy resources."
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
}

variable "vpc_azs" {
  type        = list(string)
  description = "Availability Zones for the VPC subnets."
}

variable "vpc_private_subnets" {
  type        = list(string)
  description = "CIDR blocks for private subnets."
}

variable "vpc_public_subnets" {
  type        = list(string)
  description = "CIDR blocks for public subnets."
}

variable "vpc_enable_nat_gateway" {
  type        = bool
  description = "Whether to create NAT gateways."
}

variable "vpc_single_nat_gateway" {
  type        = bool
  description = "Whether to create one NAT gateway shared across Availability Zones."
}

variable "vpc_enable_vpn_gateway" {
  type        = bool
  description = "Whether to create a VPN gateway."
}

variable "vpc_terraform" {
  type        = string
  description = "Value for the Terraform resource tag."
}

variable "vpc_environment" {
  type        = string
  description = "Value for the Environment resource tag."
}

variable "rds_identifier" {
  type        = string
  description = "DB identifier"
}

variable "rds_engine" {
  type        = string
  description = "Database engine to use for the RDS instance."
}

variable "rds_engine_version" { type = string }
variable "rds_instance_class" { type = string }
variable "rds_allocated_storage" { type = number }
variable "rds_db_name" { type = string }
variable "rds_username" { type = string }
variable "rds_port" { type = number }
variable "rds_iam_database_authentication_enabled" { type = bool }
variable "rds_maintenance_window" { type = string }
variable "rds_backup_window" { type = string }
variable "rds_monitoring_interval" { type = number }
variable "rds_monitoring_role_name" { type = string }
variable "rds_create_monitoring_role" { type = bool }
variable "rds_tags" { type = map(string) }
variable "rds_create_db_subnet_group" { type = bool }
variable "rds_family" { type = string }
variable "rds_major_engine_version" { type = string }
variable "rds_deletion_protection" { type = bool }
variable "rds_parameters" {
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string)
  }))
}
variable "rds_options" {
  type = list(object({
    option_name = string
    option_settings = list(object({
      name  = string
      value = string
    }))
  }))
}

variable "eks_name" {
  type        = string
  description = "Name of the EKS cluster."
}

variable "eks_kubernetes_version" {
  type        = string
  description = "Kubernetes version for the EKS cluster."
}

variable "eks_addons" {
  type = map(object({
    before_compute = optional(bool)
  }))
  description = "EKS addons to enable for the cluster."
}

variable "eks_endpoint_public_access" {
  type        = bool
  description = "Whether the EKS cluster endpoint is publicly accessible."
}

variable "eks_enable_cluster_creator_admin_permissions" {
  type        = bool
  description = "Whether to add the current caller identity as a cluster administrator."
}

variable "eks_managed_node_groups" {
  type = map(object({
    ami_type                     = string
    instance_types               = list(string)
    min_size                     = number
    max_size                     = number
    desired_size                 = number
    iam_role_additional_policies = optional(map(string), {})
  }))
  description = "EKS managed node group definitions."
}

variable "eks_tags" {
  type        = map(string)
  description = "Tags to apply to EKS resources."
}

variable "ecr_repositories" {
  description = "Map of ECR repositories to create. The map key is used as the repository name."
  type = map(object({
    force_delete         = optional(bool, false)
    image_tag_mutability = optional(string, "IMMUTABLE")
    scan_on_push         = optional(bool, true)
  }))
}

variable "ecr_tags" {
  description = "Tags to apply to ECR repositories."
  type        = map(string)
}

variable "alb_controller_irsa_role_name" {
  type        = string
  description = "Name of the IAM role used by the AWS Load Balancer Controller service account."
}

variable "alb_attach_load_balancer_controller_policy" {
  type        = bool
  description = "value"
}

variable "alb_controller_service_account_namespace" {
  type        = string
  description = "Kubernetes namespace for the AWS Load Balancer Controller service account."
}

variable "alb_controller_service_account_name" {
  type        = string
  description = "Kubernetes service account name used by the AWS Load Balancer Controller."
}
