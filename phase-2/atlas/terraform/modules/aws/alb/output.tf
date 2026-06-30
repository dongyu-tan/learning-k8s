output "iam_role_arn" {
  value       = module.alb_controller_irsa.iam_role_arn
  description = "ARN of the IAM role for the AWS Load Balancer Controller service account."
}

output "iam_role_name" {
  value       = module.alb_controller_irsa.iam_role_name
  description = "Name of the IAM role for the AWS Load Balancer Controller service account."
}
