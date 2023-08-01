.Phony: create-backend
create-backend: ## Create terrafor remote backend storage account
	../scripts/set-up-terraform-remote-state.sh


.Phony: init
init: ## Initialize the Terraform configuration
	terraform init

.Phony: initlock
initlock: init ## Initialize and lock providers
	terraform providers lock -platform=darwin_arm64 -platform=darwin_amd64 -platform=linux_amd64 -platform=linux_arm64

.Phony: fmt
fmt: ## formatt the .tf files
	terraform fmt -recursive

.Phony: format
format: fmt ## formatt the .tf files

.Phony: lock
lock: initlock # Initialize and lock providers

.Phony: clean
clean: ## Clean the .terraform directory
	find . -type d -name ".terraform" -prune -exec rm -rf {} \;

.Phony: clean-all
clean-all: clean ## Clean the .terraform directory and .lock.hcl with azure logout.
	find . -name ".terraform.lock.hcl" -prune -exec rm -rf {} \;
	az logout
	az account clear
