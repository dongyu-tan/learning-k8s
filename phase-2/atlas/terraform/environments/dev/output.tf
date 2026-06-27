output "s3_bucket_name" {
  description = "Name of the S3 report bucket."
  value       = module.aws_s3.bucket_name
}

output "worker_s3_policy_arn" {
  description = "ARN of the IAM policy attached to the worker node group for S3 report writes."
  value       = module.aws_s3.worker_s3_policy_arn
}
