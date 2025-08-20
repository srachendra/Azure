terraform {
  backend "azurerm" {
    resource_group_name   = "Royal-RG"
    storage_account_name  = "royalstorageaccount1"
    container_name        = "royalcontainer"
    key                   = "terraform.tfstate"
    subscription_id       = "2b1551ba-06d4-4000-8ff6-98b00d5ffa59
  }
}
