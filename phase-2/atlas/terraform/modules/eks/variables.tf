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

variable "eks_vpc_id" {
  type        = string
  description = "VPC ID where the EKS cluster is deployed."
}

variable "eks_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs where the EKS cluster and managed node groups are deployed."
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
