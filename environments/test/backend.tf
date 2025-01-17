terraform {
  backend "azurerm" {
    resource_group_name  = "supply-bridge-tfstate-rg"
    storage_account_name = "supplybridgetfstate"
    container_name      = "tfstate"
    key                 = "test.tfstate"
  }
}