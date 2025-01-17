variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "westeurope"
}

variable "key_vault_secrets" {
  description = "Map of secrets to store in Key Vault"
  type        = map(string)
  sensitive   = true
}

variable "key_vault_access_policies" {
  description = "Map of object IDs that need access to Key Vault"
  type = object({
    app_object_id       = string
    developer_object_id = string
  })
} 