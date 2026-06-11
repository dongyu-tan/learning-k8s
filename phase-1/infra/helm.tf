resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  wait = false

  set = [
    {
      name  = "clusterName"
      value = module.eks.cluster_name
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.alb_controller_irsa.iam_role_arn
    },
    {
      name  = "vpcId"
      value = aws_vpc.main.id
    }

  ]

  depends_on = [module.eks, module.alb_controller_irsa]
}
