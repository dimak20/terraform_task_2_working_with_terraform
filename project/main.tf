terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.105.0"
    }
  }
}

resource "azurerm_resource_group" "material" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "mate-storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.material.name
  location                 = azurerm_resource_group.material.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "mate-container" {
  name                  = var.container_name
  storage_account_name = azurerm_storage_account.mate-storage.name
  container_access_type = "private"
}

data "archive_file" "code_zip" {
  type        = "zip"
  source_dir  = "${path.module}"
  output_path = "${path.module}/app.zip"
}

resource "azurerm_storage_blob" "mate-blob" {
  name                   = var.blob_name
  storage_account_name   = azurerm_storage_account.mate-storage.name
  storage_container_name = azurerm_storage_container.mate-container.name
  type                   = "Block"
  source        = data.archive_file.code_zip.output_path
}
