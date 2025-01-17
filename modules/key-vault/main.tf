data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "supply_bridge" {
  name                        = "supply-bridge-${var.environment}-kv"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List", "Create", "Delete", "Update",
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete",
    ]
  }

  tags = var.tags
}

# Add additional access policies
resource "azurerm_key_vault_access_policy" "app" {
  key_vault_id = azurerm_key_vault.supply_bridge.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.key_vault_access_policies.app_object_id

  secret_permissions = [
    "Get", "List"
  ]

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      secret_permissions,
      object_id,
      tenant_id
    ]
  }
}

resource "azurerm_key_vault_access_policy" "developer" {
  key_vault_id = azurerm_key_vault.supply_bridge.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.key_vault_access_policies.developer_object_id

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Purge", "Recover"
  ]

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      secret_permissions,
      object_id,
      tenant_id
    ]
  }
}

# Create environment-specific secrets
locals {
  is_database_env = var.environment != "prod"
}

# PostgreSQL secrets (only for test and preprod)
resource "azurerm_key_vault_secret" "postgresql_admin_user" {
  count        = local.is_database_env ? 1 : 0
  name         = "postgresql-admin-user"
  value        = try(var.key_vault_secrets["postgresql_admin_user"], null)
  key_vault_id = azurerm_key_vault.supply_bridge.id
}

resource "azurerm_key_vault_secret" "postgresql_admin_password" {
  count        = local.is_database_env ? 1 : 0
  name         = "postgresql-admin-password"
  value        = try(var.key_vault_secrets["postgresql_admin_password"], null)
  key_vault_id = azurerm_key_vault.supply_bridge.id
}

# Common secrets for all environments
resource "azurerm_key_vault_secret" "app_secret_key" {
  name         = "app-secret-key"
  value        = var.key_vault_secrets["app_secret_key"]
  key_vault_id = azurerm_key_vault.supply_bridge.id
}

resource "azurerm_key_vault_secret" "api_key" {
  name         = "api-key"
  value        = var.key_vault_secrets["api_key"]
  key_vault_id = azurerm_key_vault.supply_bridge.id
}

# Cosmos DB secret (only for prod)
resource "azurerm_key_vault_secret" "cosmos_db_connection_string" {
  count        = var.environment == "prod" ? 1 : 0
  name         = "cosmos-db-connection-string"
  value        = try(var.key_vault_secrets["cosmos_db_connection_string"], null)
  key_vault_id = azurerm_key_vault.supply_bridge.id
} 