.PHONY: os.clean os.build

os.clean:
	@echo "Destroying resources..."
	$(TF_BIN) -chdir=$(LIVEOS_DIR) destroy -auto-approve

os.init:
	@echo "Initializing terraform..."
	$(TF_BIN) -chdir=$(LIVEOS_DIR) init -upgrade

os.validate: os.init
	@echo "Validating terraform scripts..."
	$(TFLINT_BIN) --chdir=$(LIVEOS_DIR)
	$(TF_BIN) -chdir=$(LIVEOS_DIR) validate

os.plan: os.validate
	@echo "Planning terraform script execution..."
	$(TF_BIN) -chdir=$(LIVEOS_DIR) plan -var="cache_dir=$(CACHE_DIR)" -var="scripts_dir=$(SBIN_DIR)" -out $(CACHE_DIR)/tfdata/liveos/plan

os.build: os.init os.validate os.plan
	@echo "Building live OS image..."
	$(TF_BIN) -chdir=$(LIVEOS_DIR) apply -auto-approve -var="cache_dir=$(CACHE_DIR)" -var="scripts_dir=$(SBIN_DIR)" $(CACHE_DIR)/tfdata/liveos/plan
	$(DOCKER_BIN) logs liveos -f
