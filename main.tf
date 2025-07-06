terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Generate unique suffixes
resource "random_id" "storage_suffix" {
  byte_length = 4
}

resource "random_id" "rg_suffix" {
  byte_length = 2
}

# Create Resource Group with unique name
resource "azurerm_resource_group" "lab4_rg" {
  name     = "lab4-rg-${random_id.rg_suffix.hex}"
  location = "westeurope"
}

# Storage Account with unique name
resource "azurerm_storage_account" "lab4_storage" {
  name                     = "lab4storage${random_id.storage_suffix.hex}"
  resource_group_name      = azurerm_resource_group.lab4_rg.name
  location                 = azurerm_resource_group.lab4_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  # Security settings
  https_traffic_only_enabled       = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
}

# Blob Storage Container
resource "azurerm_storage_container" "lab4_container" {
  name                  = "lab4container"
  storage_account_name  = azurerm_storage_account.lab4_storage.name
  container_access_type = "private"
}

# File Share
resource "azurerm_storage_share" "lab4_fileshare" {
  name                 = "lab4fileshare"
  storage_account_name = azurerm_storage_account.lab4_storage.name
  quota                = 5
}

# Table Storage
resource "azurerm_storage_table" "lab4_table" {
  name                 = "lab4table"
  storage_account_name = azurerm_storage_account.lab4_storage.name
}

# Queue Storage
resource "azurerm_storage_queue" "lab4_queue" {
  name                 = "lab4queue"
  storage_account_name = azurerm_storage_account.lab4_storage.name
}

# Outputs
output "storage_account_name" {
  value = azurerm_storage_account.lab4_storage.name
}

output "resource_group_name" {
  value = azurerm_resource_group.lab4_rg.name
}

output "blob_url" {
  value = "${azurerm_storage_account.lab4_storage.primary_blob_endpoint}${azurerm_storage_container.lab4_container.name}"
}
