
# Configure the Rancher2 provider
provider "rancher2" {
  api_url    = var.rancher_api_url
  token_key  = var.rancher_api_token

  insecure = true
}


################################## Rancher
resource "rancher2_cluster" "manager" {
  name = var.cluster-name
  description = "Testing RKE in azure"
  rke_config {
    network {
      plugin = "flannel"
      options = {
        flannel_backend_port = 4789
        flannel_backend_type = "vxlan"
        flannel_backend_vni = 4096
      }
    }
    # cloud_provider {
    #   azure_cloud_provider {
    #     aad_client_id =  module.serviceprincipal-module.application-id
    #     aad_client_secret = module.serviceprincipal-module.secret
    #     subscription_id = var.subscription-id
    #     tenant_id = var.tenant-id
    #   }
    # }
  }
}
