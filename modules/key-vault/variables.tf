variable "environment" {
  description = "Environment name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
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