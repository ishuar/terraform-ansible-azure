# Load balanced Azure linux virtual machines with Terraform

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

> For replicating on github, kindly adjust the secrets and variables mentioned in the [.github/workflows](../../.github/workflows) and update ssh keys in [ssh_keys](./ssh_keys/).

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
