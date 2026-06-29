output "ecr_repository_arns" {
  description = "ECR repository ARNs keyed by repository name."
  value       = module.aws_ecr.repository_arns
}

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

output "s3_bucket_arn" {
  description = "ARN of the S3 report bucket."
  value       = module.aws_s3.bucket_arn
}

output "s3_bucket_name" {
  description = "Name of the S3 report bucket."
  value       = module.aws_s3.bucket_name
}

output "worker_s3_policy_arn" {
  description = "ARN of the IAM policy attached to the worker node group for S3 report writes."
  value       = module.aws_s3.worker_s3_policy_arn
}
