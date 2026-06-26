module "alb_controller_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  # TODO: Update to version 6 after the first deployment
  version = "~> 5.0"

  role_name = var.role_name

  attach_load_balancer_controller_policy = var.attach_load_balancer_controller_policy

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.service_account_namespace}:${var.service_account_name}"]
    }
  }
}
