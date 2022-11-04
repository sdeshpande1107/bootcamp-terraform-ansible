provider "azurerm" {
   features {}
}


terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.28.0"
    }
  }
}

#Creating a resource group:

resource "azurerm_resource_group" "terraform" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

module "Production" {
  source = "../Modules"
  resource_group_name   = var.resource_group_name
  resource_group_location = var.resource_group_location
  db_password = var.db_password
  db_username = var.db_username
  admin_password = var.admin_password
  machine_type = var.machine_type
  postgres_server_sku = var.postgres_server_sku
  psqlservername = var.psqlservername
}