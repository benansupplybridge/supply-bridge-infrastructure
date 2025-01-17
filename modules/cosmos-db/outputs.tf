output "cosmos_db_id" {
  description = "The ID of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.supply_bridge.id
}

output "cosmos_db_endpoint" {
  description = "The endpoint of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.supply_bridge.endpoint
} 