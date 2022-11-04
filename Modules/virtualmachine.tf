

# Creating availibility set: 

resource "azurerm_availability_set" "avset" {
  name                = "avset"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  depends_on = [
    azurerm_subnet.public-subnet
  ]
}

#creating virtual machines: 

resource "azurerm_linux_virtual_machine" "app-vm" {
  count               = var.resource_vm_count
  name                = "vm-${count.index}"
  location            = azurerm_resource_group.terraform.location
  resource_group_name = azurerm_resource_group.terraform.name
  size                = var.machine_type
  admin_username      = "azureuser"
  admin_password      = var.admin_password
  availability_set_id = azurerm_availability_set.avset.id
  network_interface_ids           = [element(azurerm_network_interface.nic.*.id, count.index)]
  disable_password_authentication = false
  depends_on = [
    azurerm_availability_set.avset,
  ]

  os_disk {
    name                 = "app-disk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

