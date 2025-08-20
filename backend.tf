terraform {
  backend "azurerm" {
    resource_group_name   = "tfstate-rg"
    storage_account_name  = "royalstorageaccount1"
    container_name        = "royalcontainer"
    key                   = "terraform.tfstate"
  }
}
