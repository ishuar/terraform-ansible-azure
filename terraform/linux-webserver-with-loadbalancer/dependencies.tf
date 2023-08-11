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

resource "azurerm_network_interface_security_group_association" "webserver" {
  for_each = toset(local.webservers)

  network_interface_id      = azurerm_network_interface.public[each.value].id
  network_security_group_id = azurerm_network_security_group.webserver.id
}

####################################
##* Only valid in Local Development
####################################

data "http" "self_ip" {
  count = var.ENABLE_LOCAL_DEVELOPMENT ? 1 : 0
  url   = "https://ipinfo.io/ip"
  request_headers = {
    Accept = "application/text"
  }
}

resource "azurerm_network_security_rule" "ssh" {
  count                        = var.ENABLE_LOCAL_DEVELOPMENT ? 1 : 0
  access                       = "Allow"
  direction                    = "Inbound"
  name                         = "AllowSSH"
  priority                     = 400
  protocol                     = "Tcp"
  source_port_range            = "*"
  source_address_prefix        = data.http.self_ip[0].response_body
  destination_port_ranges      = [22]
  resource_group_name          = azurerm_resource_group.main.name
  network_security_group_name  = azurerm_network_security_group.webserver.name
  destination_address_prefixes = azurerm_subnet.webservers.address_prefixes ## Allowed SSH on the subnet level, could be hardened on NIC level.
}

#################################################################################################
#* The private key generated by this resource will be stored unencrypted in your Terraform state file.
#* Use of this resource for production deployments is not recommended.
#* Instead, generate a private key file outside of Terraform and distribute it securely to the system where Terraform will be run.
################################################################################################
locals {
  create_ssh_key_via_terraform = var.ENABLE_LOCAL_DEVELOPMENT && var.create_ssh_key_via_terraform ? true : false
}
module "ssh_key_generator" {
  count = local.create_ssh_key_via_terraform ? 1 : 0

  source               = "github.com/ishuar/terraform-sshkey-generator?ref=v1.1.0"
  algorithm            = "RSA"
  private_key_filename = "${path.module}/${var.private_key_filename}"
  file_permission      = "600"
}
