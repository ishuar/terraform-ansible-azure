###################
#### Resource Group ####
########################

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = "westeurope"
}

###################
#### Network ####
###################
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "webservers" {
  name                 = "snet-webserver"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

#########################
#### Network Security ####
########################

resource "azurerm_network_security_group" "webserver" {
  name                = "webserver"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_security_rule" "lb_to_webservers" {
  access                       = "Allow"
  direction                    = "Inbound"
  name                         = "lb-to-webservers"
  priority                     = 100
  protocol                     = "Tcp"
  source_port_range            = "*"
  source_address_prefix        = "AzureLoadBalancer"
  destination_port_ranges      = [80, 443]
  resource_group_name          = azurerm_resource_group.main.name
  network_security_group_name  = azurerm_network_security_group.webserver.name
  destination_address_prefixes = azurerm_subnet.webservers.address_prefixes
}

data "http" "self_ip" {
  url = "https://ipinfo.io/ip"
  request_headers = {
    Accept = "application/text"
  }
}

resource "azurerm_network_security_rule" "ssh" {
  access                       = "Allow"
  direction                    = "Inbound"
  name                         = "AllowSSH"
  priority                     = 101
  protocol                     = "Tcp"
  source_port_range            = "*"
  source_address_prefix        = data.http.self_ip.response_body
  destination_port_ranges      = [22]
  resource_group_name          = azurerm_resource_group.main.name
  network_security_group_name  = azurerm_network_security_group.webserver.name
  destination_address_prefixes = azurerm_subnet.webservers.address_prefixes ## Allowed SSH on the subnet level, could be hardened on NIC level.
}

resource "azurerm_network_security_rule" "http" {
  access                       = "Allow"
  direction                    = "Inbound"
  name                         = "AllowHTTP"
  priority                     = 102
  protocol                     = "Tcp"
  source_port_range            = "*"
  source_address_prefix        = "*"
  destination_port_ranges      = [80]
  resource_group_name          = azurerm_resource_group.main.name
  network_security_group_name  = azurerm_network_security_group.webserver.name
  destination_address_prefixes = azurerm_subnet.webservers.address_prefixes ## Allowed HTTP on the subnet level, could be hardened on NIC level.
}

resource "azurerm_network_interface_security_group_association" "webserver" {
  for_each = toset(local.webservers)

  network_interface_id      = azurerm_network_interface.public[each.value].id
  network_security_group_id = azurerm_network_security_group.webserver.id
}
