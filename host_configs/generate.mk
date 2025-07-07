.PHONY: host_configs.generate host_configs.clean

host_configs.clean:
	@echo "Cleaning KCL output in ..."
	rm -f $(HOSTS_DIR)/router/host_vars/router.yaml

host_configs.generate:
	@echo "Generating host_vars files..."
	mkdir $(HOSTS_DIR)/router/host_vars
	kcl run hosts/router.k --output $(HOSTS_DIR)/router/host_vars/router.yaml

