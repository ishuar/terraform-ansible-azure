resource "azurerm_public_ip" "pip" {
  for_each = toset(local.webservers)

  name                = "${each.value}-pip"
  sku                 = "Standard"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  domain_name_label   = "${local.owner}-nginx-${each.value}"
  tags                = merge(local.common_tags, local.slave_tags, { assigned_to = each.value })

}

resource "azurerm_network_interface" "public" {
  for_each = toset(local.webservers)

  name                = "${each.value}-nic1"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = merge(local.common_tags, local.slave_tags, { assigned_to = each.value })


  ip_configuration {
    name                          = "public"
    subnet_id                     = azurerm_subnet.webservers.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[each.value].id
  }
}

## Info: Add NSG rule (manually) to allow 22 to only public IP assigned to local machine to access VMs.
## Can not use "https://ipinfo.io/ip" anymore because of Github action executing the code.
locals {
  local_public_key = file("./ssh_keys/rsa-ansible-azure.pub")
  public_key       = local.create_ssh_key_via_terraform ? trimspace(module.ssh_key_generator[0].public_ssh_key) : local.local_public_key
}

resource "azurerm_linux_virtual_machine" "slaves" {
  for_each = toset(local.webservers)

  name                            = "${each.value}-vm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_B2s"
  admin_username                  = "adminuser"
  disable_password_authentication = true
  tags                            = merge(local.common_tags, local.slave_tags)
  custom_data                     = filebase64("${path.module}/../../scripts/ubuntu-change-default-ssh-port.yaml")

  network_interface_ids = [
    azurerm_network_interface.public[each.value].id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = local.public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  lifecycle {
    ignore_changes = [
      identity
    ]
  }
}
