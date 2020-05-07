# Kubernetes provider
provider "kubernetes" {
  version = "1.11.1"

  host = var.rancher_k8s.host
  client_certificate     = var.rancher_k8s.client_certificate
  client_key             = var.rancher_k8s.client_key
  cluster_ca_certificate = var.rancher_k8s.cluster_ca_certificate

  load_config_file = false
}

# Helm provider
provider "helm" {
  version = "1.1.1"

  kubernetes {
    host = var.rancher_k8s.host
    client_certificate     = var.rancher_k8s.client_certificate
    client_key             = var.rancher_k8s.client_key
    cluster_ca_certificate = var.rancher_k8s.cluster_ca_certificate

    load_config_file = false
  }
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

# Create rancher-installer service account
resource "kubernetes_service_account" "rancher_installer" {
  metadata {
    name      = "rancher-intaller"
    namespace = "kube-system"
  }

  automount_service_account_token = true
}

# Bind rancher-intall service account to cluster-admin
resource "kubernetes_cluster_role_binding" "rancher_installer_admin" {
  metadata {
    name = "${kubernetes_service_account.rancher_installer.metadata[0].name}-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.rancher_installer.metadata[0].name
    namespace = "kube-system"
  }
}

# Create and run job to install cert-manager CRDs
resource "kubernetes_job" "install_cert_manager_crds" {
  depends_on = [kubernetes_cluster_role_binding.rancher_installer_admin]

  metadata {
    name      = "install-certmanager-crds"
    namespace = "kube-system"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "kubectl"
          image   = var.kubectl_image
          command = ["kubectl", "apply", "-f", "--validate=false", var.cert_manager.crd_url]
        }
        host_network                    = true
        automount_service_account_token = true
        service_account_name            = kubernetes_service_account.rancher_installer.metadata[0].name
        restart_policy                  = "Never"
      }
    }
  }
  provisioner "local-exec" {
    command = "sleep 30s"
  }
}

# Create cert-manager namespace
resource "kubernetes_job" "create_cert_manager_ns" {
  depends_on = [kubernetes_job.install_cert_manager_crds]

  metadata {
    name      = "create-cert-manager-ns"
    namespace = "kube-system"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "kubectl"
          image   = var.kubectl_image
          command = ["kubectl", "create", "namespace", var.cert_manager.ns]
        }
        host_network                    = true
        automount_service_account_token = true
        service_account_name            = kubernetes_service_account.rancher_installer.metadata[0].name
        restart_policy                  = "Never"
      }
    }
  }
  provisioner "local-exec" {
    command = "sleep 30s"
  }
}

resource "helm_release" "cert-manager" {
  depends_on = [kubernetes_job.install_cert_manager_crds]

  name  = "cert-manager"
  namespace = var.cert_manager.ns
  repository = data.helm_repository.jetstack.metadata[0].name
  chart = "jetstack/cert-manager"
  version = var.cert_manager.version

  dynamic set {
    for_each = var.cert_manager.chart_set
    content {
      name  = set.value.name
      value = set.value.value
    }
  }

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
    value = rancher_k8s.host
  }

  set {
    name = "addLocal"
    value = "true"
  }
}

