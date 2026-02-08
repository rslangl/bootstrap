.PHONY: os.clean os.build

TF_PLAN_LIVEOS := $(CACHE_DIR)/tfdata/modules/liveos/plan

os.clean:
	@echo "Destroying resources..."
	terraform -chdir=$(LIVEOS_DIR) destroy -auto-approve

os.init:
	@echo "Initializing terraform..."
	terraform -chdir=$(LIVEOS_DIR) init -reconfigure

os.validate: os.init
	@echo "Validating terraform scripts..."
	tflint --chdir=$(LIVEOS_DIR)
	terraform -chdir=$(LIVEOS_DIR) validate

os.plan: os.validate
	@echo "Planning terraform script execution..."
	terraform -chdir=$(LIVEOS_DIR) plan -var="cache_dir=$(CACHE_DIR)" -var="scripts_dir=$(SBIN_DIR)" -out $(TF_PLAN_LIVEOS)

os.build: os.init os.validate os.plan
	@echo "Building live OS image..."
	terraform -chdir=$(LIVEOS_DIR) apply -auto-approve -var="cache_dir=$(CACHE_DIR)" -var="scripts_dir=$(SBIN_DIR)" $(TF_PLAN_LIVEOS)
	docker logs liveos -f
