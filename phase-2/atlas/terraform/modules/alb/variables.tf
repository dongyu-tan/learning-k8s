variable "role_name" {
  type        = string
  description = "Name of the IAM role used by the AWS Load Balancer Controller service account."
}

variable "attach_load_balancer_controller_policy" {
  type        = bool
  description = "Value of Attached Load Balancer Controlelr Policy"
}

variable "oidc_provider_arn" {
  type        = string
  description = "ARN of the EKS cluster OIDC provider."
}

variable "service_account_namespace" {
  type        = string
  description = "Kubernetes namespace for the AWS Load Balancer Controller service account."
}

variable "service_account_name" {
  type        = string
  description = "Kubernetes service account name used by the AWS Load Balancer Controller."
}
