variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "westeurope"
}

variable "postgresql_sku" {
  description = "PostgreSQL SKU name"
  type        = string
  default     = "GP_Gen5_2"
}

variable "postgresql_storage_mb" {
  description = "PostgreSQL storage in MB"
  type        = number
  default     = 5120
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

variable "allowed_ip_address" {
  description = "IP address to allow access to PostgreSQL"
  type        = string
} 