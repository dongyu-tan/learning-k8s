output "cluster_name" {
  value       = module.eks.cluster_name
  description = "Name of the EKS cluster."
}

output "oidc_provider_arn" {
  value       = module.eks.oidc_provider_arn
  description = "ARN of the EKS cluster OIDC provider."
}
