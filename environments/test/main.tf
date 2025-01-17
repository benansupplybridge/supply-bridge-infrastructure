terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

locals {
  environment = "test"
  location    = var.location
  tags = {
    Environment = local.environment
    Project     = "Supply Bridge"
    ManagedBy   = "Terraform"
  }
}

# Resource Group
resource "azurerm_resource_group" "supply_bridge" {
  name     = "supply-bridge-${local.environment}-rg"
  location = local.location
  tags     = local.tags
}

# Key Vault Module
module "key_vault" {
  source                   = "../../modules/key-vault"
  resource_group_name      = azurerm_resource_group.supply_bridge.name
  location                = local.location
  environment             = local.environment
  tags                    = local.tags
  key_vault_secrets       = var.key_vault_secrets
  key_vault_access_policies = var.key_vault_access_policies
}

# Add these data sources before the PostgreSQL module
data "azurerm_key_vault_secret" "postgresql_admin_user" {
  name         = "postgresql-admin-user"
  key_vault_id = module.key_vault.key_vault_id
  depends_on   = [module.key_vault]
}

data "azurerm_key_vault_secret" "postgresql_admin_password" {
  name         = "postgresql-admin-password"
  key_vault_id = module.key_vault.key_vault_id
  depends_on   = [module.key_vault]
}

# PostgreSQL Module
module "postgresql" {
  source              = "../../modules/postgresql"
  resource_group_name = azurerm_resource_group.supply_bridge.name
  location           = local.location
  environment        = local.environment
  tags               = local.tags
  key_vault_id       = module.key_vault.key_vault_id
  postgresql_sku     = var.postgresql_sku
  postgresql_storage_mb = var.postgresql_storage_mb
  admin_username = data.azurerm_key_vault_secret.postgresql_admin_user.value
  admin_password = data.azurerm_key_vault_secret.postgresql_admin_password.value
  allowed_ip_address = var.allowed_ip_address
} 