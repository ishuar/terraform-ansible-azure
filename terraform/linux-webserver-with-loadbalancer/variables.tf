variable "prefix" {
  type        = string
  default     = "ansible-vm"
  description = "(optional) Prefix used for naming resources"
}

variable "ENABLE_LOCAL_DEVELOPMENT" {
  type        = bool
  default     = true
  description = "(optional) Whether to enable Flag for local development or working from the hostmachine directly or not. Default is true"
}

variable "private_key_filename" {
  type        = string
  description = "(optional) SSH private key filename create by terraform will be stored on your local machine in ssh_keys directory."
  default     = "ssh_keys/terraform-generated-private-key"
}

variable "create_ssh_key_via_terraform" {
  type        = bool
  description = "(optional) Whether to enable ssh key generation via terraform or not. Defaults to true"
  default     = true
}
