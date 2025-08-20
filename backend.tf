terraform {
  backend "azurerm" {
    resource_group_name   = "Royal-RG"
    storage_account_name  = "royalstorageaccount1"
    container_name        = "royalcontainer"
    key                   = "terraform.tfstate"
    use_azuread_auth      = true
    subscription_id       = "2b1551ba-06d4-4000-8ff6-98b00d5ffa59"
    tenant_id             = "6e437120-99de-480f-bca4-0a53d8ac8fd6"
  }
}
