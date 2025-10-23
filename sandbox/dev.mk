.PHONY: dev.clean dev.build

DEV_TF_PLAN := $(CACHE_DIR)/tfdata/sandbox/plan
TF_BIN := $(TOOLS_DIR)/terraform

dev.clean:
	@echo "Destroying resources..."
	$(TF_BIN) -chdir=$(SANDBOX_DIR) destroy -auto-approve
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
	$(TF_BIN) -chdir=$(SANDBOX_DIR) plan -var="cache_dir=$(CACHE_DIR)" -out $(DEV_TF_PLAN)

dev.build: dev.init dev.validate dev.plan
	@echo "Setting up host system..."
	ansible-playbook $(SANDBOX_DIR)/playbooks/host_pre.yaml --tags setup
	@echo "Creating resources..."
	$(TF_BIN) -chdir=$(SANDBOX_DIR) apply -var="cache_dir=$(CACHE_DIR)" -auto-approve $(DEV_TF_PLAN)
