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

variable "tags" {
  description = "Resource tags"
  type        = map(string)
}

variable "key_vault_id" {
  description = "Key Vault ID for storing secrets"
  type        = string
}

variable "admin_username" {
  description = "PostgreSQL administrator username"
  type        = string
  default     = "psqladmin"
}

variable "admin_password" {
  description = "PostgreSQL administrator password"
  type        = string
  sensitive   = true
}

variable "allowed_ip_address" {
  description = "IP address to allow access to PostgreSQL"
  type        = string
} 