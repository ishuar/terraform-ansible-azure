terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
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
