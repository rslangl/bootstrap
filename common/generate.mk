.PHONY: generate clean

HOSTS := router
HOST_VARS_DIR := $(RESOURCES_DIR)/host_vars

clean:
	@echo "Cleaning KCL output in $(HOST_VARS_DIR)..."
	rm -f $(HOST_VARS_DIR)/*.yaml

generate:
	@echo "Generating host_vars files to $(HOST_VARS_DIR)..."
	@mkdir -p $(HOST_VARS_DIR)
	kcl run common/router.k --output $(HOST_VARS_DIR)/router.yaml

