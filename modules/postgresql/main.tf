resource "azurerm_postgresql_server" "supply_bridge" {
  name                = "supply-bridge-${var.environment}-psql"
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password

  sku_name   = var.postgresql_sku
  version    = "11"
  storage_mb = var.postgresql_storage_mb

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled           = true

  public_network_access_enabled    = true
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"

  tags = var.tags
}

# Add database creation
resource "azurerm_postgresql_database" "supply_bridge" {
  name                = "supply_bridge_${var.environment}"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.supply_bridge.name
  charset             = "UTF8"
  collation          = "English_United States.1252"
}

# Add firewall rule to allow Azure services
resource "azurerm_postgresql_firewall_rule" "azure_services" {
  name                = "allow-azure-services"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.supply_bridge.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# Add firewall rule to allow your IP
resource "azurerm_postgresql_firewall_rule" "allow_my_ip" {
  name                = "allow-my-ip"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.supply_bridge.name
  start_ip_address    = var.allowed_ip_address
  end_ip_address      = var.allowed_ip_address
}

# Store PostgreSQL password in Key Vault
resource "azurerm_key_vault_secret" "postgresql_password" {
  name         = "supply-bridge-${var.environment}-psql-password"
  value        = var.admin_password
  key_vault_id = var.key_vault_id
} 