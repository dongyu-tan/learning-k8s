output "bucket_arn" {
  description = "ARN of the S3 report bucket."
  value       = aws_s3_bucket.report.arn
}

output "bucket_name" {
  description = "Name of the S3 report bucket."
  value       = aws_s3_bucket.report.id
}

output "worker_s3_policy_arn" {
  description = "ARN of the IAM policy that allows workers to write report objects."
  value       = aws_iam_policy.worker_s3.arn
}
