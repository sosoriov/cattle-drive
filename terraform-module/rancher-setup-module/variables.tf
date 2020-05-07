variable "lets-encrypt-email" {
  description = "Email addres for lets encrypt"
}

variable "lets-encrypt-environment" {
  description = "Which lets encrypt environment staging/production"
}

variable "rancher_k8s" {
  type = object({
    host = string
    client_certificate = string
    client_key = string
    cluster_ca_certificate = string
  })
  description = "K8s cluster client configuration"
}

variable "kubectl_image" {
  type        = string
  description = "Kubectl docker image"
  default     = "bitnami/kubectl:1.17.4"
}

variable "cert_manager" {
  type = object({
    ns = string
    version = string
    crd_url = string
    chart_set = list(object({
      name = string
      value = string
    }))
  })
  default = {
    ns = "cert-manager"
    version = "v0.14.2"
    crd_url = "https://raw.githubusercontent.com/jetstack/cert-manager/release-0.14/deploy/manifests/00-crds.yaml"
    chart_set = []
  }
  description = "Cert-manager helm chart properties. Chart sets can be added using chart_set param"
}