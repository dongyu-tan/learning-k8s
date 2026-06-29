output "iam_role_arn" {
  description = "ARN of the IAM role for the Atlas worker service account."
  value       = module.worker_irsa.iam_role_arn
}

output "iam_role_name" {
  description = "Name of the IAM role for the Atlas worker service account."
  value       = module.worker_irsa.iam_role_name
}
