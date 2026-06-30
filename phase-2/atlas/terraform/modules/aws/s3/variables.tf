variable "s3_bucket_name" {
  description = "Name of the S3 bucket used for worker reports."
  type        = string
}

variable "s3_force_destroy" {
  description = "Whether to allow Terraform to delete the bucket even when it contains objects."
  type        = bool
  default     = false
}

variable "s3_tags" {
  description = "Tags to apply to S3 and related IAM resources."
  type        = map(string)
  default     = {}
}
