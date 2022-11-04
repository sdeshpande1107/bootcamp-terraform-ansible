# Creating load balancer and required rules: 

resource "azurerm_lb" "load-balancer" {
  name                = "load-balancer"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "public-ip-config"
    public_ip_address_id = azurerm_public_ip.lb-public-ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "lb-bepool" {
  name            = "lb-bepool"
  loadbalancer_id = azurerm_lb.load-balancer.id
}

resource "azurerm_lb_probe" "health-probe" {
  name            = "lb-health-probe"
  loadbalancer_id = azurerm_lb.load-balancer.id
  port            = var.backendport
}

resource "azurerm_lb_rule" "tf" {
  loadbalancer_id                = azurerm_lb.load-balancer.id
  name                           = "lb-rule"
  protocol                       = "Tcp"
  frontend_port                  = var.backendport
  backend_port                   = var.backendport
  frontend_ip_configuration_name = "public-ip-config"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb-bepool.id]
  probe_id                       = azurerm_lb_probe.health-probe.id
}


#load balancer NAT rule: 

resource "azurerm_lb_nat_rule" "lb-nat-rule" {
  count                          = var.resource_vm_count
  resource_group_name            = azurerm_resource_group.terraform.name
  loadbalancer_id                = azurerm_lb.load-balancer.id
  name                           = "lb-nat-ssh-${count.index}"
  protocol                       = "Tcp"
  frontend_port                  = "40${count.index}"
  backend_port                   = var.sshport
  frontend_ip_configuration_name = "public-ip-config"
}

#NAT rule asssociation: 

resource "azurerm_network_interface_nat_rule_association" "nat-association" {
  count                 = var.resource_vm_count
  network_interface_id  = azurerm_network_interface.nic[count.index].id
  ip_configuration_name = "app-${count.index}-nic"
  nat_rule_id           = azurerm_lb_nat_rule.lb-nat-rule[count.index].id
}
 
resource "azurerm_lb_backend_address_pool_address" "tf-lb-bepool-addr" {
  count                   = var.resource_vm_count
  name                    = "lb-bepool-address-${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-bepool.id
  virtual_network_id      = azurerm_virtual_network.vnet.id
  ip_address              = azurerm_network_interface.nic[count.index].private_ip_address

}
