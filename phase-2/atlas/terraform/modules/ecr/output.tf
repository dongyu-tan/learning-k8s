output "repository_arns" {
  description = "ARNs of the ECR repositories."
  value       = { for name, repository in aws_ecr_repository.repository : name => repository.arn }
}

output "repository_names" {
  description = "Names of the ECR repositories."
  value       = { for name, repository in aws_ecr_repository.repository : name => repository.name }
}

output "repository_urls" {
  description = "URLs of the ECR repositories."
  value       = { for name, repository in aws_ecr_repository.repository : name => repository.repository_url }
}
