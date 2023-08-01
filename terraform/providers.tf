terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.50"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-ansible-terraform"
    storage_account_name = "stgansiteraweu01"
    container_name       = "tfstate"
    key                  = "ansible-terraform"
  }
}
