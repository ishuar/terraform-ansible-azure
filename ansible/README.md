## Table of Contents

- [Ansible Configuration and Roles Documentation](#ansible-configuration-and-roles-documentation)
  - [Roles](#roles)
    - [`azure_vm_ufw` Role](#azure_vm_ufw-role)
    - [`nginx_webserver` Role](#nginx_webserver-role)
  - [Local Development Environment](#local-development-environment)
    - [Azure Dynamic Inventory](#azure-dynamic-inventory)
      - [Prerequisites for Azure Dynamic Inventory for Local Environment.](#prerequisites-for-azure-dynamic-inventory-for-local-environment)
    - [Example `.env` File](#example-env-file)
    - [Running the playbook Locally](#running-the-playbook-locally)
  - [Help Articles](#help-articles)

# Ansible Configuration and Roles Documentation

Welcome to the Ansible section of our repository! Here you'll find all the information you need to configure your Azure dynamic inventory, utilize two roles (`azure_vm_ufw` and `nginx_webserver`), and even set up your local development environment using the provided example `.env` file.

>> This document already assumes that ansible ,python3 and pip3 are installed by now.

## Roles

### `azure_vm_ufw` Role

The [`azure_vm_ufw`](./roles/azure_vm_ufw/) role is designed to manage the Uncomplicated Firewall (UFW) on Azure virtual machines. This role ensures that the required ports are open and rules are set according to your specifications.

### `nginx_webserver` Role

The [`nginx_webserver`](./roles/nginx_webserver/) role sets up an Nginx web server on Azure virtual machines. It installs Nginx, configures it to serve static content, and manages the service.

## Local Development Environment

### Azure Dynamic Inventory

We've configured Ansible to use the Azure dynamic inventory plugin, which enables dynamic inventory management of Azure resources. This means you don't need to maintain an inventory file manually. Instead, Ansible fetches real-time inventory directly from your Azure account.

To use the Azure dynamic inventory, ensure you have the Azure CLI installed and authenticated. Ansible will utilize your Azure credentials to fetch the inventory.

#### Prerequisites for Azure Dynamic Inventory for Local Environment.

- Ansible version >= `2.9`
- ansible-galaxy Collection `azure.azcollection`

Use the below commands to install the requirements.
```bash
$ pip3 install msrest -I
$ ansible-galaxy collection install azure.azcollection
$ pip3 install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements-azure.txt
```

Refer to the [Ansible azcollection](https://galaxy.ansible.com/azure/azcollection?extIdCarryOver=true&sc_cid=701f2000001OH7YAAW) documentation for more information.


### Example `.env` File

We've included an `example.env` file to help you set up your local development environment. This file contains environment variables required to authenticate with Azure and configure Ansible. Please refer to the [example.env](example.env) file in this directory for details on required variables and their descriptions.

Before you begin, copy the `example.env` file to `.env` and fill in the appropriate values for your environment. Make sure to keep sensitive information like Azure credentials secure.

<details>
<summary>Click to view details of `example.env` file.</summary>

```bash
#!/usr/bin/env bash

## Ansible Env Vars:
## https://docs.ansible.com/ansible/latest/scenario_guides/guide_azure.html
## https://learn.microsoft.com/en-us/azure/developer/ansible/install-on-linux-vm?tabs=azure-cli#create-azure-credentials

export AZURE_CLIENT_ID=""                     ## Azure client ID
export AZURE_SECRET=""                        ## Azure client secret ID
export AZURE_TENANT=""                        ## Azure tenant ID
export AZURE_SUBSCRIPTION_ID=""               ## Azure subscription ID

```
</details>
</br>

- Load your `*.env` file to terminal session
```bash
## In case you are creating your own *.env file, use below command else ignore
$ chmod +x <your-env-file-name>.env

## This is required to load your env vars, make sure you are in ansible directory
./example.env ## or ## ./<your-env-file-name>.env
```

> Add `*.env` in your `.gitignore` to avoid commiting secrets to Version control.

### Running the playbook Locally

```bash
$ ansible-playbook set-up-ubuntu-nginx-webserver.yaml -i my.azure_rm.yaml --private-key <path-to-your-private-key>
```

## Help Articles

1. [Ansible azure_rm_inventory](https://docs.ansible.com/ansible/latest/collections/azure/azcollection/azure_rm_inventory.html)
2. [ Microsoft Tutorial for Dynamic Inventory](https://learn.microsoft.com/en-us/azure/developer/ansible/dynamic-inventory-configure?tabs=azure-cli)
3. [Ansible azcollection](https://galaxy.ansible.com/azure/azcollection?extIdCarryOver=true&sc_cid=701f2000001OH7YAAW)
4. [azure_vm_ufw role](./roles/azure_vm_ufw/README.md)
5. [nginx_webserver role](./roles/nginx_webserver/README.md)
6. [Getting Started With Ansible](https://docs.ansible.com/ansible/latest/getting_started/index.html)

