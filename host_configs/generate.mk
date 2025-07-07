.PHONY: host_configs.generate host_configs.clean

host_configs.clean:
	@echo "Cleaning KCL output in ..."
	rm -f $(HOSTS_DIR)/router/host_vars/router.yaml

host_configs.generate:
	@echo "Generating host_vars files..."
	kcl run $(HOSTS_CONFIG_DIR)/hosts/router.k --output $(HOSTS_DIR)/router/host_vars/router.yaml

