#!/usr/bin/env bash

set -ue

printf '\e[1;31m%-6s\e[0m\n' "### IMPORTANT NOTE ###: Please login to azure first using az login and set up correct azure subscription"
printf '\e[1;31m%-6s\e[0m\n' "az login                                         => Login to azure cli."
printf '\e[1;31m%-6s\e[0m\n' "az account list --output table                   => Check which Azure accounts/subscriptions you have."
printf '\e[1;31m%-6s\e[0m\n' "az account set -s <your-azure-subscription-id>   => Set the right azure account."

cat <<-EOF

Default Values for locaion, resource group, storage account and container name are set..
To over ride the values, please export below environment variables with required values:

### YOUR VALUE HAS TO BE REPLACED WITH YOUR REQUIRED INPUT ###

export LOCATION="YOUR VALUE"
export RESOURCE_GROUP_NAME="YOUR VALUE"
export STORAGE_ACCOUNT_NAME="YOUR VALUE"
export CONTAINER_NAME="YOUR VALUE"

EOF

printf '\e[1;32m%-6s\e[0m' "Kindly Read above Info and Press yes or y to continue: "
read -r RESPONSE
echo ""
# LOWER_CASE_RESPONSE="$(echo "$RESPONSE" | tr '[:upper:]' '[:lower:]')"
LOWER_CASE_RESPONSE="$(echo "$RESPONSE" | awk '{ print tolower($1) }')"
## Default Values
LOCATION=${LOCATION:-"westeurope"}
RESOURCE_GROUP_NAME=${RESOURCE_GROUP_NAME:-"rg-ansible-terraform"}
STORAGE_ACCOUNT_NAME=${STORAGE_ACCOUNT_NAME:-"stgansiteraweu01"}
CONTAINER_NAME=${CONTAINER_NAME:-"tfstate"}

if [[ "$LOWER_CASE_RESPONSE" == "yes" || "$LOWER_CASE_RESPONSE" == "y" ]]; then

  printf "#######################################################################\n"
  printf "#### Creating Storage Account for Terraform backend configuration ####\n"
  printf "#######################################################################\n\n"
  if [[ $(command -v az) ]]; then
    # Check and Create resource group
    if ! az group exists --name "$RESOURCE_GROUP_NAME" &>/dev/null; then
      az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION"
    else
      echo "-> Resource group with name $RESOURCE_GROUP_NAME already exists"
    fi

    # Create and Check storage account
    if ! az storage account show --resource-group "$RESOURCE_GROUP_NAME" --name "$STORAGE_ACCOUNT_NAME" &>/dev/null; then
      az storage account create --resource-group "$RESOURCE_GROUP_NAME" --name "$STORAGE_ACCOUNT_NAME" --sku Standard_LRS --encryption-services blob
    else
      echo "-> Storage Account with name $STORAGE_ACCOUNT_NAME already exists, please use another globally unique name"
    fi

    # Get storage account key, Create and Check blob container
    ACCOUNT_KEY=$(az storage account keys list --resource-group "$RESOURCE_GROUP_NAME" --account-name "$STORAGE_ACCOUNT_NAME" --query "[0].value" -o tsv)
    if ! az storage container show --account-name "$STORAGE_ACCOUNT_NAME" --name "$CONTAINER_NAME" --account-key "$ACCOUNT_KEY" &>/dev/null; then
      az storage container create --name "$CONTAINER_NAME" --account-name "$STORAGE_ACCOUNT_NAME" --account-key "$ACCOUNT_KEY"
    else
      echo "-> Storage Container with name  $CONTAINER_NAME  already exists in storage account $STORAGE_ACCOUNT_NAME"
    fi

    printf '\e[1;32m%-6s\e[0m\n' "Resource Group Name: $RESOURCE_GROUP_NAME"
    printf '\e[1;32m%-6s\e[0m\n' "Storage Account Name: $STORAGE_ACCOUNT_NAME"
    printf '\e[1;32m%-6s\e[0m\n' "Terraform State Container Name: $CONTAINER_NAME"
    printf '\e[1;31m%-6s\e[0m\n' "Configure the terraform backend with the above configurations"

  else
    if [[ $(command -v brew) ]]; then
      brew install az
    else
      echo "please Install az cli using https://learn.microsoft.com/en-us/cli/azure/install-azure-cli"
    fi
  fi
else
  echo "Did you change your mind, No worries meet the requirements and come back again"
fi
