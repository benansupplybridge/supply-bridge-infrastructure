output "server_name" {
  description = "The name of the PostgreSQL server"
  value       = azurerm_postgresql_server.supply_bridge.name
}

output "server_fqdn" {
  description = "The fully qualified domain name of the PostgreSQL server"
  value       = azurerm_postgresql_server.supply_bridge.fqdn
} 