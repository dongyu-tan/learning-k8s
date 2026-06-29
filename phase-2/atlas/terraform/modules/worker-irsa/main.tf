module "worker_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = var.role_name

  role_policy_arns = {
    s3_reports_write = var.worker_s3_policy_arn
  }

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.service_account_namespace}:${var.service_account_name}"]
    }
  }

  tags = var.tags
}
