terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

variable "resource_group_name" {
  type = string
}

variable "storage_account_name" {
  type = string
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "lab4_rg" {
  name     = var.resource_group_name
  location = "westeurope"
}

resource "azurerm_storage_account" "lab4_storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.lab4_rg.name
  location                 = azurerm_resource_group.lab4_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"
}

resource "azurerm_storage_container" "lab4_container" {
  name                  = "lab4container"
  storage_account_name  = azurerm_storage_account.lab4_storage.name
  container_access_type = "private"
}

resource "azurerm_storage_share" "lab4_fileshare" {
  name                 = "lab4fileshare"
  storage_account_name = azurerm_storage_account.lab4_storage.name
  quota                = 5
}

resource "azurerm_storage_table" "lab4_table" {
  name                 = "lab4table"
  storage_account_name = azurerm_storage_account.lab4_storage.name
}

resource "azurerm_storage_queue" "lab4_queue" {
  name                 = "lab4queue"
  storage_account_name = azurerm_storage_account.lab4_storage.name
}

output "endpoints" {
  value = {
    blob_url  = "${azurerm_storage_account.lab4_storage.primary_blob_endpoint}${azurerm_storage_container.lab4_container.name}"
    file_share = "${azurerm_storage_account.lab4_storage.primary_file_endpoint}${azurerm_storage_share.lab4_fileshare.name}"
  }
}
