.PHONY: os.clean os.build

TF_PLAN := $(CACHE_DIR)/tfdata/liveos/plan
TF_BIN := $(TOOLS_DIR)/terraform

export TF_DATA_DIR
export TF_PLUGIN_CACHE_DIR

os.clean:
	@echo "Destroying resources..."
	$(TF_BIN) -chdir=$(LIVEOS_DIR) destroy -auto-approve

os.init:
	@echo "Initializing terraform..."
	$(TF_BIN) -chdir=$(LIVEOS_DIR) init -upgrade

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
	docker logs liveos -f
	@if [ -f "$(CACHE_DIR)/output/liveUSB.iso" ]; then \
		$(TF_BIN) -chdir=$(LIVEOS_DIR) destroy -auto-approve \
	fi
