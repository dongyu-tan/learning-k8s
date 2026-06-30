output "aws_rds_endpoint" {
  description = "The connection endpoint for RDS instance"
  value       = module.db.db_instance_endpoint
}

output "aws_rds_master_user_secret_arn" {
  description = "ARN of the RDS master user secret in AWS Secrets Manager."
  value       = module.db.db_instance_master_user_secret_arn
}
