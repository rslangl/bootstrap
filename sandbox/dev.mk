.PHONY: dev.clean dev.build

ISO_REL_PATH := $(CACHE_DIR)/images/opnsense.iso
ISO_ABS_PATH := $(abspath $(ISO_REL_PATH))
TF_PLAN := $(CACHE_DIR)/tfstate/sandbox/plan

dev.clean:
	@echo "Destroying resources..."
	terraform destroy -auto-approve -var="opnsense_iso_path=$(ISO_ABS_PATH)"

dev.init:
	@echo "Initializing Terraform..."
	terraform init

dev.validate:
	terraform validate

dev.plan:
	@echo "Planning with ISO at $(ISO_ABS_PATH)..."
	terraform plan -var="opnsense_iso_path=$(ISO_ABS_PATH)" -out $(TF_PLAN)

dev.build: dev.init dev.validate dev.plan
	terraform apply -auto-approve -var="opnsense_iso_path=$(ISO_ABS_PATH)" $(TF_PLAN)
