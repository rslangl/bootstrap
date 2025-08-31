.PHONY: os.clean os.build

TF_DATA_DIR := $(shell mkdir -p ../.cache/tfdata && realpath -m ../.cache/tfdata)
TF_PLUGIN_CACHE_DIR := $(TF_DATA_DIR)/liveos/plugin-cache
TF_PLAN := $(CACHE_DIR)/tfdata/liveos/plan
TF_BIN := $(TOOLS_DIR)/terraform

export TF_DATA_DIR
export TF_PLUGIN_CACHE_DIR

os.clean:
	@echo "Destroying resources..."
	$(TF_BIN) -chdir=$(LIVEOS_DIR) destroy -auto-approve

os.init:
	@echo "Initializing terraform..."
	$(TF_BIN) -chdir=$(LIVEOS_DIR) init -migrate-state

os.validate: os.init
	@echo "Validating terraform scripts..."
	tflint --chdir=$(LIVEOS_DIR)
	$(TF_BIN) -chdir=$(LIVEOS_DIR) validate

os.plan: os.validate
	@echo "Planning terraform script execution..."
	$(TF_BIN) -chdir=$(LIVEOS_DIR) plan -var="cache_dir=$(CACHE_DIR)" -var="scripts_dir=$(SBIN_DIR)" -out $(TF_PLAN)

os.build: os.init os.validate os.plan 
	@echo "Building live OS image..."
	$(TF_BIN) -chdir=$(LIVEOS_DIR) apply -auto-approve -var="cache_dir=$(CACHE_DIR)" -var="scripts_dir=$(SBIN_DIR)" $(TF_PLAN)
