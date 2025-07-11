.PHONY: host_configs.generate host_configs.clean

host_configs.clean:
	@echo "Cleaning KCL output in ..."
	rm -f $(HOSTS_DIR)/router/ansible/host_vars/router.yaml
	rm -f $(HOSTS_DIR)/kvm/ansible/host_vars/kvm.yaml

host_configs.generate:
	@echo "Generating host_vars files..."
	kcl run $(HOSTS_CONFIG_DIR)/hosts/router.k --output $(HOSTS_DIR)/router/ansible/host_vars/router.yaml
	kcl run $(HOSTS_CONFIG_DIR)/hosts/kvm.k --output $(HOSTS_DIR)/kvm/ansible/host_vars/kvm.yaml

