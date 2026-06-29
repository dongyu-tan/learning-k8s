variable "oidc_provider_arn" {
  description = "ARN of the EKS cluster OIDC provider."
  type        = string
}

variable "role_name" {
  description = "Name of the IAM role used by the Atlas worker service account."
  type        = string
}

variable "service_account_name" {
  description = "Kubernetes service account name used by the Atlas worker."
  type        = string
}

variable "service_account_namespace" {
  description = "Kubernetes namespace for the Atlas worker service account."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the worker IRSA role."
  type        = map(string)
}

variable "worker_s3_policy_arn" {
  description = "ARN of the IAM policy that allows workers to write report objects."
  type        = string
}
