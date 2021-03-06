provider "helm" {
  kubernetes {
    config_path = var.kubeconfig-path
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig-path
}

data "helm_repository" "rancher-stable" {
  name = "rancher-stable"
  url  = "https://releases.rancher.com/server-charts/stable"
}

data "helm_repository" "rancher-latest" {
  name = "rancher-latest"
  url  = "https://releases.rancher.com/server-charts/latest"
}

data "helm_repository" "jetstack" {
  name = "jetstack"
  url = "https://charts.jetstack.io"
}


resource "helm_release" "cert-manager" {
  name  = "cert-manager"
  namespace = "cert-manager"
  repository = data.helm_repository.jetstack.metadata[0].name
  chart = "jetstack/cert-manager"
  version = "v0.14.3"
  timeout = "600"
  wait = true
}

resource "kubernetes_namespace" "cattle-system" {
  metadata {
    name = "cattle-system"
  }
}

resource "helm_release" "rancher" {
  depends_on = [helm_release.cert-manager, kubernetes_namespace.cattle-system]

  name  = "rancher"
  namespace = "cattle-system"
  repository = data.helm_repository.rancher-latest.metadata[0].name
  chart = "rancher-latest/rancher"
  version = "v2.3.5"
  timeout = 600
  wait = true

  set {
    name = "ingress.tls.source"
    value = "letsEncrypt"
  }

  set {
    name = "letsEncrypt.email"
    value = var.lets-encrypt-email
  }

  set {
    name = "letsEncrypt.environment"
    value = var.lets-encrypt-environment
  }

  set {
    name = "hostname"
    value = var.rancher-hostname
  }

  set {
    name = "addLocal"
    value = "true"
  }
}

