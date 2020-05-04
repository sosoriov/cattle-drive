provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=2.0.0"
  features {}
}

resource "azuread_application" "ad-application" {
  name                       = var.application-name
  homepage                   = "https://${var.application-name}"
  identifier_uris            = ["http://${var.application-name}"]
  available_to_other_tenants = false
}

resource "azuread_service_principal" "service-principal" {
  application_id                = azuread_application.ad-application.application_id
  app_role_assignment_required  = true
}


resource "azurerm_role_assignment" "serviceprincipal-role" {
  scope                = var.resource-group-id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.service-principal.id
}

resource "azuread_service_principal_password" "service-principal-password" {
  service_principal_id = azuread_service_principal.service-principal.id
  value                = var.password
  end_date_relative    = "720h"
}