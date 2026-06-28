resource "helm_release" "alb_controller" {
  count = var.alb_controller.enabled ? 1 : 0

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = var.alb_controller.namespace
  version    = var.alb_controller.chart_version

  wait = var.alb_controller.wait

  set = [
    {
      name  = "clusterName"
      value = var.cluster.name
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = var.alb_controller.service_account_name
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = var.alb_controller.irsa_role_arn
    },
    {
      name  = "vpcId"
      value = var.cluster.vpc_id
    }
  ]
}
