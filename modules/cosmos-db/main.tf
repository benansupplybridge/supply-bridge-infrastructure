resource "azurerm_cosmosdb_account" "supply_bridge" {
  name                = "supply-bridge-${var.environment}-cosmos"
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  automatic_failover_enabled = true

  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  tags = var.tags
}

# Add database creation
resource "azurerm_cosmosdb_sql_database" "supply_bridge" {
  name                = "supply_bridge_${var.environment}"
  resource_group_name = azurerm_cosmosdb_account.supply_bridge.resource_group_name
  account_name        = azurerm_cosmosdb_account.supply_bridge.name
  throughput          = var.environment == "prod" ? 400 : 400
}

# Add container creation
resource "azurerm_cosmosdb_sql_container" "supply_bridge" {
  name                = "main"
  resource_group_name = azurerm_cosmosdb_account.supply_bridge.resource_group_name
  account_name        = azurerm_cosmosdb_account.supply_bridge.name
  database_name       = azurerm_cosmosdb_sql_database.supply_bridge.name
  partition_key_path  = "/id"
}

# Store Cosmos DB key in Key Vault
resource "azurerm_key_vault_secret" "cosmos_primary_key" {
  name         = "supply-bridge-${var.environment}-cosmos-primary-key"
  value        = azurerm_cosmosdb_account.supply_bridge.primary_key
  key_vault_id = var.key_vault_id
}
