
resource "kubernetes_config_map" "logstash_pipeline" {
  metadata {
    name = "logstash-pipeline-config"
  }

  data = {
    "uptime.conf" = file("../pipelines/uptime.conf")
  }
}

resource "kubernetes_config_map" "python_script" {
  metadata {
    name = "python-script"
  }

  data = {
    "main.py" = file("../src/main.py")
  }
}

resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = "7.17.3"

  values = [
    file("../helm-values/elastic-values.yaml")
  ]

  timeout = 600
}

resource "helm_release" "logstash" {
  name       = "logstash"
  repository = "https://helm.elastic.co"
  chart      = "logstash"
  version    = "7.17.3"

  values = [
    file("../helm-values/logstash-values.yaml")
  ]

  depends_on = [
    kubernetes_config_map.logstash_pipeline,
    helm_release.elasticsearch
  ]
}

resource "helm_release" "kibana" {
  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  version    = "7.17.3"

  values = [
    file("../helm-values/kibana-values.yaml")
  ]

  depends_on = [
    helm_release.elasticsearch
  ]
}

resource "kubernetes_manifest" "log_generator" {
  manifest = yamldecode(file("../k8s/log-generator-deploy.yaml"))

  depends_on = [
    kubernetes_config_map.python_script
  ]
}