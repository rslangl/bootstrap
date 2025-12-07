.PHONY: cfg.generate cfg.clean

# KCL_BIN := $(TOOLS_DIR)/kcl

cfg.clean:
	@echo "Cleaning KCL output in ..."
	rm -f $(HOSTS_DIR)/router/ansible/host_vars/router.yaml
	rm -f $(HOSTS_DIR)/kvm/ansible/host_vars/kvm.yaml

cfg.generate:
	@echo "Generating host_vars files..."
	$(KCL_BIN) run $(HOSTS_CONFIG_DIR)/hosts/kvm.k --output $(HOSTS_DIR)/kvm/ansible/host_vars/kvm.yaml
	$(KCL_BIN) run $(HOSTS_CONFIG_DIR)/hosts/router.k --output $(HOSTS_DIR)/router/ansible/host_vars/router.yaml

cfg.validate: cfg.generate
	@echo "Validating generated files..."
	$(KCL_BIN) vet $(HOSTS_DIR)/kvm/ansible/host_vars/kvm.yaml $(HOSTS_CONFIG_DIR)/hosts/kvm.k --format yaml
	$(KCL_BIN) vet $(HOSTS_DIR)/router/ansible/host_vars/router.yaml $(HOSTS_CONFIG_DIR)/hosts/router.k --format yaml
