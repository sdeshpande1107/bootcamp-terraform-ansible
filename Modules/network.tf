# Creating virtual network: 

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.resource_group_location
  address_space       = ["192.168.0.0/24"]
  resource_group_name = azurerm_resource_group.terraform.name
}

#Creating Public Subnet:

resource "azurerm_subnet" "public-subnet" {
  name                 = "public-subnet"
  address_prefixes     = ["192.168.0.0/25"]
  resource_group_name  = azurerm_resource_group.terraform.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}


#Creating Private Subnet: 

resource "azurerm_subnet" "private-subnet" {
  name                 = "private-subnet"
  address_prefixes     = ["192.168.0.128/26"]
  resource_group_name  = azurerm_resource_group.terraform.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

#create public network security group and rules: 

resource "azurerm_network_security_group" "public-nsg" {
  name                = "public-nsg"
  location            = azurerm_resource_group.terraform.location
  resource_group_name = azurerm_resource_group.terraform.name

  security_rule {
    access                     = "Allow"
    description                = "AllowSSH"
    destination_address_prefix = "*"
    source_address_prefixes    = ["14.141.60.58","182.72.58.210", "103.51.72.244", "103.51.72.234"]
    direction                  = "Inbound"
    name                       = "AllowSSHInBound"
    priority                   = 110
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.sshport
  }
   
  security_rule {
    access                     = "Allow"
    description                = "AllowWebapp"
    destination_address_prefix = "*"
    source_address_prefix      = "*"
    direction                  = "Inbound"
    name                       = "AllowWebAppInBound"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.backendport
  }
  
  security_rule {
    access                     = "Deny"
    description                = "Deny all ports"
    destination_address_prefix = "*"
    destination_port_range     = "*"
    direction                  = "Inbound"
    name                       = "DenyAll"
    priority                   = 600
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }

  
}

#create private network security group and rules:

resource "azurerm_network_security_group" "private-nsg" {
  name                = "private-nsg"
  location            = azurerm_resource_group.terraform.location
  resource_group_name = azurerm_resource_group.terraform.name

  security_rule {
    access                     = "Allow"
    description                = "AllowSSH"
    destination_address_prefix = "*"
    source_address_prefix      = "10.0.0.32/27"
    direction                  = "Inbound"
    name                       = "AllowSSHInBound"
    priority                   = 110
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.sshport
  }

  security_rule {
    access                     = "Allow"
    description                = "AllowPostgres"
    destination_address_prefix = "*"
    source_address_prefix      = "10.0.0.32/27"
    direction                  = "Inbound"
    name                       = "AllowPostgresInBound"
    priority                   = 120
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 5432
  }

  security_rule {
    access                     = "Deny"
    description                = "Deny all ports"
    destination_address_prefix = "*"
    destination_port_range     = "*"
    direction                  = "Inbound"
    name                       = "DenyAll"
    priority                   = 500
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }

}

#Connecting security group to public subnet:

resource "azurerm_subnet_network_security_group_association" "public-nsg-association" {
  subnet_id                 = azurerm_subnet.public-subnet.id
  network_security_group_id = azurerm_network_security_group.public-nsg.id
}

#Connecting security group to priate subnet: 

resource "azurerm_subnet_network_security_group_association" "private-nsg-association" {
  subnet_id                 = azurerm_subnet.private-subnet.id
  network_security_group_id = azurerm_network_security_group.private-nsg.id
}

#Creating Network Interface: 

resource "azurerm_network_interface" "nic" {
  count               = var.resource_vm_count
  name                = "app-${count.index}-nic"
  location            = azurerm_resource_group.terraform.location
  resource_group_name = azurerm_resource_group.terraform.name

  ip_configuration {
    name                          = "app-${count.index}-nic"
    subnet_id                     = azurerm_subnet.public-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}


#creating public ip for load balancer:

resource "azurerm_public_ip" "lb-public-ip" {
  name                = "lb-public-ip"
  sku                 = "Standard"
  location            = azurerm_resource_group.terraform.location
  resource_group_name = azurerm_resource_group.terraform.name
  allocation_method   = "Static"
}

/*

# Creating public ip's for vm's

resource "azurerm_public_ip" "public_ip-for-vm" {
  count = var.resource_vm_count
  name                = "vm_public_ip-${count.index}"
  sku                 = "Standard"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  allocation_method   = "Static"
}

*/