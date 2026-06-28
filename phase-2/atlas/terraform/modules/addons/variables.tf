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

variable "cluster" {
  description = "Shared EKS cluster context required by addon Helm releases."
  type = object({
    name   = string
    vpc_id = string
  })
}
