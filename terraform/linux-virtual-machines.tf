resource "azurerm_public_ip" "pip" {
  for_each = toset(local.webservers)

  name                = "${each.value}-pip"
  sku                 = "Standard"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  domain_name_label   = "${local.owner}-nginx-${each.value}"
}

resource "azurerm_network_interface" "public" {
  for_each = toset(local.webservers)

  name                = "${each.value}-nic1"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "public"
    subnet_id                     = azurerm_subnet.webservers.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[each.value].id
  }
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


  network_interface_ids = [
    azurerm_network_interface.public[each.value].id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/rsa-ansible-azure.pub")
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

## REMOTE-EXEC PROVISIONER ##
# connection {
#   type     = "ssh"
#   user     = "adminuser"
#   password = var.root_password
#   host     = self.public_ip
# }

# provisioner "remote-exec" {
#   inline = [
#     "puppet apply",
#     "consul join ${aws_instance.web.private_ip}",
#   ]
# }



# ## LOCAL ANSIBLE OPERATIONS: configure remote ansible master.

# resource "terraform_data" "ansible" {

#   triggers_replace = [
#     azurerm_linux_virtual_machine.master.id,
#     ##! to retrigger the local-exec provisioner whenever there are changes in master set up playbook or the command.
#     ##* Increment the master_set_up_playbook_revision whenver there is a change in master set up playbook or the command.
#     local.master_set_up_playbook_revision
#   ]

#   provisioner "local-exec" {

#     command = <<-EOT
#     ssh-keygen -R ${azurerm_public_ip.pip.fqdn}
#     ssh-keyscan -H ${azurerm_public_ip.pip.fqdn} >> ~/.ssh/known_hosts
#     for i in $(seq 30); do echo wait for ${azurerm_linux_virtual_machine.master.name} VM provisioning; sleep 1; done
#     ansible-playbook set-up-master-playbook.yaml --extra-vars='dynamicHosts=${keys(local.master_tags)[2]}_${local.master_tags.role}' -i my.azure_rm.yaml --private-key ~/.ssh/rsa-ansible-azure
#     EOT

#     interpreter = [
#       "/bin/bash", "-c"
#     ]
#   }
# }
