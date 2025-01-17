output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.supply_bridge.id
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.supply_bridge.vault_uri
} 