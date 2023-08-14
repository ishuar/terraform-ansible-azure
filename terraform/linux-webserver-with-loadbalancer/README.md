# Load balanced Azure linux virtual machines with Terraform

## Introduction

This directory provides terraform configurations to provison load balanced linux virtual machines on [Microsoft Azure]() cloud platform. Further these machines can be any assigned any role. For this repository context they are configurred as Nginx Webservers hosting static web application using [Ansible]().

## Prerequisites

In order to re-use the configurations please check the below tool matrix:

| Name          | Version Used | Help                                                                                                 | Required |
|---------------|--------------|------------------------------------------------------------------------------------------------------|----------|
| Terraform     | `>= 1.1.0`   | [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) | Yes      |
| Make          | `3.81`       | [Download Make](https://www.gnu.org/software/make/#download)                                         | Yes      |
| azure-cli     | `2.50.0`     | [Install azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)                   | Yes      |
| homebrew      | `4.1.3`      | [Homebrew Installation](https://docs.brew.sh/Installation)                                           | No       |
| Azure Account | `N/A`        | [Create Azure account](https://azure.microsoft.com/en-us/free)                                       | yes      |

If you have `homebrew` installed , all tools can be installed with command `brew install <Name>`, except Azure Account 😁

## Assumption

1. This Guide is created for someone to replicate the infrastructre provisioning from their local machine standpoint.

> For replicating on github, kindly adjust the secrets and variables mentioned in the [.github/workflows](../../.github/workflows) and update ssh keys in [ssh\_keys](./ssh\_keys/).

1. In order to follow this guide , it is assumed that this repostory is either cloned or forked and the same folder structure is available on the end user machine. Entire guide context is from the [`terraform/linux-webserver-with-loadbalancer`](../terraform/linux-webserver-with-loadbalancer) directory.

Command Reference:
```bash
git clone https://github.com/ishuar/terraform-ansible.git
cd terraform-ansible/terraform/linux-webserver-with-loadbalancer/
```

## Provisioning

Here, we will utilise [Makefile](./Makefile) commands for an easy installation/provisioning.

>**INFO:** Use `make help` command to know its usage.

### Terraform Backend Configuration

Its a best practice to use  [remote](https://developer.hashicorp.com/terraform/language/settings/backends/remote) backends for terraform, in this guide we are using specifically [azurerm](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm) remote backend. Kindly refer to [Example Configuration
](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm#example-configuration) for more details on its configuration.

#### Sign into Azure Account

We can use any appropriate method to authenticate to azure resource manager, in this guide we will utilise the `az login`

1. Run `az login` command

If the CLI can open your default browser, it initiates authorization code flow and open the default browser to load an Azure sign-in page.
Otherwise, it initiates the device code flow and tell you to open a browser page at https://aka.ms/devicelogin and enter the code displayed in your terminal.
If no web browser is available or the web browser fails to open, you may force device code flow with az login --use-device-code.

2. Sign in with your account credentials in the browser.

>**INFO:** Contributor rights would be preferred with the account signed in, defining IAM is out of scope for this project.

#### Create infrastructure required for remote backend

Use below command to create [`Resource Group`](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#what-is-a-resource-group), [`Storage Account`](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview), and [`Container`](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-overview)

```bash
make create-backend
```

In the backend it is using the [set-up-terraform-remote-state.sh](../scripts/set-up-terraform-remote-state.sh) shell script.

>**IMPORTANT:** ⚠️ Please set atleast `STORAGE_ACCOUNT_NAME` environment variable to over-ride the default name used in script, as the storage account names are **globally** unique OR use below command.

```bash
## If you want to set env var and create backend at the same time.
STORAGE_ACCOUNT_NAME=<globaly_unique_storage_account_name> make create-backend
```

#### Configure Terraform azurerm backend

In the [providers.tf](./providers.tf) adjust the below parameters

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-ansible-terraform" ## Optional, if over-ride by env var in step Create infrastructure required for remote backend
    storage_account_name = "STORAGE_ACCOUNT_NAME" ## Required, set STORAGE_ACCOUNT_NAME as env var.
    container_name       = "tfstate"              ## Optional, if over-ride by env var in step Create infrastructure required for remote backend
    key                  = "ansible-terraform"    ## Optional, if over-ride by env var in step Create infrastructure required for remote backend
  }
}
```

### Terraform Plan

Once the backend configuration is set up, we can start with terraform actions. Plan is generally optional in local workflows however a good practice for dry-run configurations.

- Use below commands to generate the terraform plan.

```bash
make init
make plan
```
>**INFO:** Use `make help` command to know its usage.

### Terraform Apply

Once we are satisfied with the plan, configurations can be applied to provison the infrastructure.

- Use below command to apply the configuration.

```bash
make apply
```

>**IMPORTANT** By Default a new SSH Key pair is generated and private key is saved in `ssh_keys` directory. This is not recommended in production for security reasons and SSH key should be generated out of terraform scope and [`local_public_key`](./linux-virtual-machines.tf) local variable should be updated with the correct path to SSH key.

#### Getting the Loadbalancer FQDN

After terraform apply the loadbalancer fqdn should be printed as `loadbalancer_frontend_fqdn` output, however there is a make command available to print it afterwards too.

Use any of the below command to get loadbalancer fully qualified domain name
```bash
make lb-fqdn
### OR ###
make lb-url
```

### Destroy the Infrastructure

Once you are done with your testing or want to de-provision the infrastructure. The whole azure infrastrucutre can be deleted with the below command

```bash
make destroy
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.50 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.67.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ssh_key_generator"></a> [ssh\_key\_generator](#module\_ssh\_key\_generator) | github.com/ishuar/terraform-sshkey-generator | v1.1.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_lb.web_lb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | resource |
| [azurerm_lb_backend_address_pool.nginx_webservers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_probe.web_lb_probe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) | resource |
| [azurerm_lb_rule.web_lb_rule_app1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) | resource |
| [azurerm_linux_virtual_machine.slaves](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_backend_address_pool_association.web_nic_lb_associate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_backend_address_pool_association) | resource |
| [azurerm_network_interface_security_group_association.webserver](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.webserver](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.azurecloud](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.lb_to_webservers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.ssh](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_public_ip.loadbalancer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip.pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.webservers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [http_http.self_ip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ENABLE_LOCAL_DEVELOPMENT"></a> [ENABLE\_LOCAL\_DEVELOPMENT](#input\_ENABLE\_LOCAL\_DEVELOPMENT) | (optional) Whether to enable Flag for local development or working from the hostmachine directly or not. Default is true | `bool` | `true` | no |
| <a name="input_create_ssh_key_via_terraform"></a> [create\_ssh\_key\_via\_terraform](#input\_create\_ssh\_key\_via\_terraform) | (optional) Whether to enable ssh key generation via terraform or not. Defaults to true | `bool` | `true` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | (optional) Prefix used for naming resources | `string` | `"ansible-vm"` | no |
| <a name="input_private_key_filename"></a> [private\_key\_filename](#input\_private\_key\_filename) | (optional) SSH private key filename create by terraform will be stored on your local machine in ssh\_keys directory. | `string` | `"ssh_keys/terraform-generated-private-key"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_loadbalancer_frontend_fqdn"></a> [loadbalancer\_frontend\_fqdn](#output\_loadbalancer\_frontend\_fqdn) | Fully qualified domain name for loadbalancer front end to reach backend webservers |
| <a name="output_nsg_name"></a> [nsg\_name](#output\_nsg\_name) | Network Security group name |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | Resource group where all resources are deployed |
| <a name="output_webservers_snet_address_prefix"></a> [webservers\_snet\_address\_prefix](#output\_webservers\_snet\_address\_prefix) | Webservers Subnet Address prefix |

## License

MIT License. See [LICENSE](https://github.com/ishuar/terraform-ansible/blob/main/LICENSE) for full details.