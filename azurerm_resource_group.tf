locals {
  resource_group_name = format("%s_rg", local.name)
}

resource "azurerm_resource_group" "aad_test" {
  name     = local.resource_group_name
  location = var.location
}