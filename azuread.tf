locals {
  data_access_sp_name = format("aad-storage-ps-reader-%s", local.name)
}

resource "azuread_application" "aadsp" {
  name                       = local.data_access_sp_name
  identifier_uris            = [format("https://uri-%s", local.data_access_sp_name)]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
}


# Create a Service Principal
resource "azuread_service_principal" "aadsp" {
  application_id               = azuread_application.aadsp.application_id
  app_role_assignment_required = false
}

# Generate random string to be used for Service Principal password
resource "random_string" "password" {
  length  = 24
  special = false
}

# Create a Password for that Service Principal
resource "azuread_service_principal_password" "aadsp" {
  service_principal_id = azuread_service_principal.aadsp.id
  value                = random_string.password.result
  end_date_relative    = "17520h" #expire in 2 years
}

resource "azurerm_key_vault_secret" "client_id" {
  name         = "aad-ps-client-id"
  value        = azuread_application.aadsp.application_id
  key_vault_id = azurerm_key_vault.keyvault.id

}

resource "azurerm_key_vault_secret" "client_secret" {
  name         = "aad-ps-client-secret"
  value        = azuread_service_principal_password.aadsp.value
  key_vault_id = azurerm_key_vault.keyvault.id
}

# resource "azuread_group" "readers" {
#   name = format("A-Reader-Group-for-%s", local.name)
# }


# resource "azuread_group_member" "aadsp" {
#   group_object_id  = azuread_group.readers.id
#   member_object_id = azuread_service_principal.aadsp.id
# }


resource "azurerm_role_assignment" "aadsp" {
  scope                = azurerm_storage_account.tgt_storage.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azuread_service_principal.aadsp.id
}

resource "azurerm_role_assignment" "rg_assignment" {
  scope                = azurerm_resource_group.aad_test.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.aadsp.id
}