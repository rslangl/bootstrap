.PHONY: os.clean os.build

TF_DATA_DIR := $(shell realpath ../.cache/tfdata)
TF_PLAN := $(CACHE_DIR)/tfdata/liveos/plan

os.clean:
	@echo "Destroying resources..."
	TF_DATA_DIR=$(TF_DATA_DIR) terraform -chdir=$(LIVEOS_DIR) destroy -auto-approve

os.init:
	@echo "Initializing terraform..."
	TF_DATA_DIR=$(TF_DATA_DIR) terraform -chdir=$(LIVEOS_DIR) init -migrate-state

os.validate: os.init
	@echo "Validating terraform scripts..."
	tflint --chdir=$(LIVEOS_DIR)
	TF_DATA_DIR=$(TF_DATA_DIR) terraform -chdir=$(LIVEOS_DIR) validate

os.plan: os.validate
	@echo "Planning terraform script execution..."
	TF_DATA_DIR=$(TF_DATA_DIR) terraform -chdir=$(LIVEOS_DIR) plan -var="cache_dir=$(CACHE_DIR)" -var="scripts_dir=$(SBIN_DIR)" -out $(TF_PLAN)

os.build: os.init os.validate os.plan 
	@echo "Building live OS image..."
	TF_DATA_DIR=$(TF_DATA_DIR) terraform -chdir=$(LIVEOS_DIR) apply -auto-approve -var="cache_dir=$(CACHE_DIR)" -var="scripts_dir=$(SBIN_DIR)" $(TF_PLAN)
