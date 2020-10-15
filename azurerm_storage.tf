locals {
  storage_name = format("%stgt", local.name)
  container    = "raw"
}

# Create storage account for  storage
resource "azurerm_storage_account" "tgt_storage" {
  name                     = local.storage_name
  resource_group_name      = azurerm_resource_group.aad_test.name
  location                 = azurerm_resource_group.aad_test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}

resource "azurerm_storage_container" "tgt_container" {
  name                  = local.container
  storage_account_name  = azurerm_storage_account.tgt_storage.name
  container_access_type = "private"
}

data "azurerm_monitor_diagnostic_categories" "tgt_storage" {
  resource_id = azurerm_storage_account.tgt_storage.id
}

resource "azurerm_monitor_diagnostic_setting" "tgt_storage" {
  name                       = local.storage_name
  target_resource_id         = azurerm_storage_account.tgt_storage.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.oms.id

  dynamic "metric" {
    iterator = metric_category
    for_each = data.azurerm_monitor_diagnostic_categories.tgt_storage.metrics

    content {
      category = metric_category.value
      enabled  = true

      retention_policy {
        enabled = true
        days    = var.log_retention_days
      }
    }
  }
}

