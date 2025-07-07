.PHONY: generate clean

HOSTS := router

clean:
	@echo "Cleaning KCL output in ..."
	rm -f $(HOSTS_DIR)/router/host_vars/router.yaml

generate:
	@echo "Generating host_vars files..."
	mkdir $(HOSTS_DIR)/router/host_vars
	kcl run hosts/router.k --output $(HOSTS_DIR)/router/host_vars/router.yaml

