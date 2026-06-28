output "cluster_certificate_authority_data" {
  value       = module.eks.cluster_certificate_authority_data
  description = "Base64 encoded certificate data required to connect to the EKS cluster."
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "Endpoint URL for the EKS Kubernetes API server."
}

output "cluster_name" {
  value       = module.eks.cluster_name
  description = "Name of the EKS cluster."
}

output "oidc_provider_arn" {
  value       = module.eks.oidc_provider_arn
  description = "ARN of the EKS cluster OIDC provider."
}

output "node_security_group_id" {
  value       = module.eks.node_security_group_id
  description = "ID of the EKS node shared security group."
}
