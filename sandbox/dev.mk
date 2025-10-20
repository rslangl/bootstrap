.PHONY: dev.clean dev.build

# TODO: fix paths
ISO_REL_PATH := $(CACHE_DIR)/images/opnsense.iso
ISO_ABS_PATH := $(abspath $(ISO_REL_PATH))

DEV_TF_PLAN := $(CACHE_DIR)/tfdata/sandbox/plan
TF_BIN := $(TOOLS_DIR)/terraform

dev.clean:
	@echo "Destroying resources..."
	$(TF_BIN) -chdir=$(SANDBOX_DIR) destroy -auto-approve -var="opnsense_iso_path=$(ISO_ABS_PATH)"
	@echo "Resetting host system..."
	ansible-playbook $(SANDBOX_DIR)/playbooks/host_pre.yaml --tags teardown

dev.init:
	@echo "Initializing Terraform..."
	$(TF_BIN) -chdir=$(SANDBOX_DIR) init -upgrade

dev.validate: dev.init
	tflint --chdir=$(SANDBOX_DIR)
	$(TF_BIN) -chdir=$(SANDBOX_DIR) validate

dev.plan: dev.validate
	@echo "Planning with ISO at $(ISO_ABS_PATH)..."
	$(TF_BIN) -chdir=$(SANDBOX_DIR) plan -var="opnsense_iso_path=$(ISO_ABS_PATH)" -out $(DEV_TF_PLAN)

dev.build: dev.init dev.validate dev.plan
	@echo "Setting up host system..."
	ansible-playbook $(SANDBOX_DIR)/playbooks/host_pre.yaml --tags setup
	@echo "Creating resources..."
	$(TF_BIN) -chdir=$(SANDBOX_DIR) apply -auto-approve -var="opnsense_iso_path=$(ISO_ABS_PATH)" $(DEV_TF_PLAN)
