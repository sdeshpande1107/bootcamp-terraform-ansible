
#create postgres subnet:

resource "azurerm_subnet" "vmss-postgres-subnet" {
  name                 = "postgres-subnet"
  address_prefixes     = ["192.168.0.192/26"]
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  service_endpoints    = ["Microsoft.Storage"]
  depends_on = [
    azurerm_virtual_network.vnet
  ]

  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}


#postgres flex private dns zone:

resource "azurerm_private_dns_zone" "postgres-tf" {
  name                = "example.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
  depends_on = [
    azurerm_resource_group.terraform
  ]
}


#postgres flex server dns zone vnet link:

resource "azurerm_private_dns_zone_virtual_network_link" "tf-postgres" {
  name                  = "postgres-pvt-dns-zone-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.postgres-tf.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = var.resource_group_name
  registration_enabled = true
  depends_on = [
    azurerm_resource_group.terraform
  ]
}

# Creating postgresql flexible server :

resource "azurerm_postgresql_flexible_server" "psqlflexibleserver" {
  name                   = var.psqlservername
  resource_group_name    = var.resource_group_name
  location               = var.resource_group_location
  version                = "12"
  delegated_subnet_id    = azurerm_subnet.vmss-postgres-subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.postgres-tf.id
  administrator_login    = var.db_username
  administrator_password = var.db_password
  #zone                   = "1"

  storage_mb = 32768

  sku_name   = var.postgres_server_sku
  depends_on = [azurerm_private_dns_zone_virtual_network_link.tf-postgres, azurerm_subnet.vmss-postgres-subnet]
}

resource "azurerm_postgresql_flexible_server_configuration" "backslash_quote" {
  name      = "backslash_quote"
  server_id = azurerm_postgresql_flexible_server.psqlflexibleserver.id
  value     = "off"
  depends_on = [
    azurerm_subnet.vmss-postgres-subnet
  ]
}


