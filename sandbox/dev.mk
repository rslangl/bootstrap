.PHONY: dev.clean dev.build

# TF_BIN := $(TOOLS_DIR)/terraform
# TFLINT_BIN := $(TOOLS_DIR)/tflint
# ANSIBLE_BIN := $(TOOLS_DIR)/ansible/bin/ansible-playbook

dev.clean:
	@echo "Destroying resources..."
	$(TF_BIN) -chdir=$(SANDBOX_DIR) destroy -auto-approve
	@echo "Resetting host system..."
	$(ANSIBLE_BIN) $(SANDBOX_DIR)/playbooks/host_pre.yaml --tags teardown

dev.init:
	@echo "Initializing Terraform..."
	$(TF_BIN) -chdir=$(SANDBOX_DIR) init -upgrade

dev.validate: dev.init
	$(TFLINT_BIN) --chdir=$(SANDBOX_DIR)
	$(TF_BIN) -chdir=$(SANDBOX_DIR) validate

dev.plan: dev.validate
	@echo "Planning with ISO at $(ISO_ABS_PATH)..."
	$(TF_BIN) -chdir=$(SANDBOX_DIR) plan -var="cache_dir=$(CACHE_DIR)" -out $(CACHE_DIR)/tfdata/sandbox/plan

dev.build: dev.init dev.validate dev.plan
	@echo "Setting up host system..."
	$(ANSIBLE_BIN) $(SANDBOX_DIR)/playbooks/host_pre.yaml --tags setup
	@echo "Converting live image to QCOW2..."
	qemu-img convert -f raw -O qcow2 -o preallocation=metadata,cluster_size=65536 $(CACHE_DIR)/output/liveUSB.iso $(CACHE_DIR)/vm_disks/liveos.qcow2
	@echo "Creating resources..."
	$(TF_BIN) -chdir=$(SANDBOX_DIR) apply -var="cache_dir=$(CACHE_DIR)" -auto-approve $(CACHE_DIR)/tfdata/sandbox/plan
