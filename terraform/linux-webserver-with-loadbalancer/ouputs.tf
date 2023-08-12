output "loadbalancer_frontend_fqdn" {
  value       = azurerm_public_ip.loadbalancer.fqdn
  description = "Fully qualified domain name for loadbalancer front end to reach backend webservers"
}

output "resource_group" {
  value       = azurerm_resource_group.main.name
  description = "Resource group where all resources are deployed"
}

output "nsg_name" {
  value       = azurerm_network_security_group.webserver.name
  description = "Network Security group name"
}

output "webservers_snet_address_prefix" {
  value       = azurerm_subnet.webservers.address_prefixes[0]
  description = "Webservers Subnet Address prefix"
}
