terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.28.0"
    }
  }
}

# Configure the Microsoft Azure Provider: 

provider "azurerm" {
  subscription_id = "8538752c-8045-4b0c-9625-4ccf956e1360"
  tenant_id       = "da7b62c5-f816-49a8-a183-bbc200edd15f"
  client_id       = "8387ef75-4f87-43e9-9f44-0e77208f355f"
  client_secret   = "XlU8Q~gud6iwFq16H8BBOlcxPxIgT3MSP-9IJa2C"
  features {}
}

#Creating a resource group:

resource "azurerm_resource_group" "terraform" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

