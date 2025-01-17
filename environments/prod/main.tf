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
  environment = "prod"
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

module "cosmos_db" {
  source              = "../../modules/cosmos-db"
  resource_group_name = azurerm_resource_group.supply_bridge.name
  location           = local.location
  environment        = local.environment
  tags               = local.tags
  key_vault_id       = module.key_vault.key_vault_id
} 