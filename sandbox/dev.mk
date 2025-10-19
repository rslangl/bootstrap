.PHONY: dev.clean dev.build

ISO_REL_PATH := $(CACHE_DIR)/images/opnsense.iso
ISO_ABS_PATH := $(abspath $(ISO_REL_PATH))
TF_PLAN := $(CACHE_DIR)/tfstate/sandbox/plan

dev.clean:
	@echo "Destroying resources..."
	terraform -chdir=$(SANDBOX_DIR) destroy -auto-approve -var="opnsense_iso_path=$(ISO_ABS_PATH)"

dev.init:
	@echo "Initializing Terraform..."
	terraform -chdir=$(SANDBOX_DIR) init

dev.validate: dev.init
	tflint --chdir=$(SANDBOX_DIR)
	terraform -chdir=$(SANDBOX_DIR) validate

dev.plan: dev.validate
	@echo "Planning with ISO at $(ISO_ABS_PATH)..."
	terraform -chir=$(SANDBOX_DIR) plan -var="opnsense_iso_path=$(ISO_ABS_PATH)" -out $(TF_PLAN)

dev.build: dev.init dev.validate dev.plan
	terraform -chdir=$(SANDBOX_DIR) apply -auto-approve -var="opnsense_iso_path=$(ISO_ABS_PATH)" $(TF_PLAN)
