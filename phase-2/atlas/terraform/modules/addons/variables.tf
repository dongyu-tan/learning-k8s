variable "alb_controller" {
  description = "Configuration for the AWS Load Balancer Controller Helm release."
  type = object({
    chart_version        = optional(string)
    enabled              = optional(bool, true)
    irsa_role_arn        = string
    namespace            = string
    service_account_name = string
    wait                 = optional(bool, true)
  })
}

variable "argocd" {
  description = "Configuration for the Argo CD Helm release."
  type = object({
    chart_version = optional(string)
    enabled       = optional(bool, true)
    namespace     = optional(string, "argocd")
    release_name  = optional(string, "argocd")
    wait          = optional(bool, true)
  })
  default = {}
}

variable "cluster" {
  description = "Shared EKS cluster context required by addon Helm releases."
  type = object({
    name   = string
    vpc_id = string
  })
}

variable "prometheus_stack" {
  description = "Configuration for the kube-prometheus-stack Helm release."
  type = object({
    chart_version = optional(string)
    enabled       = optional(bool, true)
    namespace     = optional(string, "monitoring")
    release_name  = optional(string, "monitoring")
    timeout       = optional(number, 600)
    wait          = optional(bool, true)
  })
  default = {}
}
