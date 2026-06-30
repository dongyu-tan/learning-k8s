resource "helm_release" "prometheus_stack" {
  count = var.prometheus_stack.enabled ? 1 : 0

  name             = var.prometheus_stack.release_name
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = var.prometheus_stack.namespace
  create_namespace = true
  version          = var.prometheus_stack.chart_version
  timeout          = var.prometheus_stack.timeout

  wait = var.prometheus_stack.wait

  set = [
    {
      name  = "alertmanager.service.type"
      value = "ClusterIP"
    },
    {
      name  = "grafana.service.type"
      value = "ClusterIP"
    },
    {
      name  = "prometheus.service.type"
      value = "ClusterIP"
    }
  ]
}
