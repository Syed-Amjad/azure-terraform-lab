# Configure Azure Provider
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

# Generate random ID for storage account
resource "random_id" "storage_suffix" {
  byte_length = 4
}

# 1. Create Resource Group
resource "azurerm_resource_group" "lab4_rg" {
  name     = "Lab4-RG-Terraform"
  location = "westeurope"
}

# 2. Create Storage Account (updated with current properties)
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

  identity {
    type = "SystemAssigned"
  }
}

# 3. Blob Storage Container
resource "azurerm_storage_container" "lab4_container" {
  name                  = "lab4container"
  storage_account_name  = azurerm_storage_account.lab4_storage.name
  container_access_type = "private"
}

# Upload a sample file using storage account key
resource "null_resource" "upload_blob" {
  provisioner "local-exec" {
    command = <<EOT
      echo "Hello from Terraform-managed Blob Storage" > blobfile.txt
      az storage blob upload \
        --account-name ${azurerm_storage_account.lab4_storage.name} \
        --container-name ${azurerm_storage_container.lab4_container.name} \
        --name blobfile.txt \
        --file blobfile.txt \
        --auth-mode key \
        --account-key $(az storage account keys list \
          --account-name ${azurerm_storage_account.lab4_storage.name} \
          --resource-group ${azurerm_resource_group.lab4_rg.name} \
          --query "[0].value" -o tsv)
    EOT
  }
}

# 4. File Share
resource "azurerm_storage_share" "lab4_fileshare" {
  name                 = "lab4fileshare"
  storage_account_name = azurerm_storage_account.lab4_storage.name
  quota                = 5
}

# 5. Table Storage
resource "azurerm_storage_table" "lab4_table" {
  name                 = "lab4table"
  storage_account_name = azurerm_storage_account.lab4_storage.name
}

# Insert sample data using storage account key
resource "null_resource" "insert_table_data" {
  provisioner "local-exec" {
    command = <<EOT
      az storage entity insert \
        --table-name ${azurerm_storage_table.lab4_table.name} \
        --entity PartitionKey=demo RowKey=001 Name=Amjad Score=100 \
        --account-name ${azurerm_storage_account.lab4_storage.name} \
        --account-key $(az storage account keys list \
          --account-name ${azurerm_storage_account.lab4_storage.name} \
          --resource-group ${azurerm_resource_group.lab4_rg.name} \
          --query "[0].value" -o tsv)
    EOT
  }
}

# 6. Queue Storage
resource "azurerm_storage_queue" "lab4_queue" {
  name                 = "lab4queue"
  storage_account_name = azurerm_storage_account.lab4_storage.name
}

# Send a test message using storage account key
resource "null_resource" "queue_message" {
  provisioner "local-exec" {
    command = <<EOT
      az storage message put \
        --queue-name ${azurerm_storage_queue.lab4_queue.name} \
        --content "Message from Terraform" \
        --account-name ${azurerm_storage_account.lab4_storage.name} \
        --account-key $(az storage account keys list \
          --account-name ${azurerm_storage_account.lab4_storage.name} \
          --resource-group ${azurerm_resource_group.lab4_rg.name} \
          --query "[0].value" -o tsv)
    EOT
  }
}

# Outputs
output "storage_account_name" {
  value = azurerm_storage_account.lab4_storage.name
}

output "blob_url" {
  value = "${azurerm_storage_account.lab4_storage.primary_blob_endpoint}${azurerm_storage_container.lab4_container.name}/blobfile.txt"
}
