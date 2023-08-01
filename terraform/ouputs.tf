output "loadbalancer_frontend_fqdn" {
  value       = azurerm_public_ip.loadbalancer.fqdn
  description = "Fully qualified domain name for loadbalancer front end to reach backend webservers"
}
