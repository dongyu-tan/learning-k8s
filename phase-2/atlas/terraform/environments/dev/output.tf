# output "ecr_repository_arns" {
#   description = "ECR repository ARNs keyed by repository name."
#   value       = module.aws_ecr.repository_arns
# }

output "ecr_repository_names" {
  description = "ECR repository names keyed by repository name."
  value       = module.aws_ecr.repository_names
}

output "ecr_repository_urls" {
  description = "ECR repository URLs keyed by repository name."
  value       = module.aws_ecr.repository_urls
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint."
  value       = module.aws_rds.aws_rds_endpoint
}

# output "s3_bucket_arn" {
#   description = "ARN of the S3 report bucket."
#   value       = module.aws_s3.bucket_arn
# }

output "s3_bucket_name" {
  description = "Name of the S3 report bucket."
  value       = module.aws_s3.bucket_name
}

# output "worker_s3_policy_arn" {
#   description = "ARN of the IAM policy attached to the worker node group for S3 report writes."
#   value       = module.aws_s3.worker_s3_policy_arn
# }

# output "worker_irsa_role_arn" {
#   description = "ARN of the IAM role for the Atlas worker service account."
#   value       = module.worker_irsa.iam_role_arn
# }

output "worker_irsa_role_name" {
  description = "Name of the IAM role for the Atlas worker service account."
  value       = module.worker_irsa.iam_role_name
}

output "rds_master_user_secret_arn" {
  description = "ARN of the RDS master user secret in AWS Secrets Manager."
  value       = module.aws_rds.aws_rds_master_user_secret_arn
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.aws_eks.cluster_name
}
