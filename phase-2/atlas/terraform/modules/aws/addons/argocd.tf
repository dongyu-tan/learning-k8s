resource "helm_release" "argocd" {
  count = var.argocd.enabled ? 1 : 0

  name             = var.argocd.release_name
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = var.argocd.namespace
  create_namespace = true
  version          = var.argocd.chart_version

  wait = var.argocd.wait

  set = [
    {
      name  = "server.service.type"
      value = "ClusterIP"
    }
  ]
}
