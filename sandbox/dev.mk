.PHONY: dev.clean dev.build

TF_PLAN_SANDBOX := $(CACHE_DIR)/tfdata/modules/sandbox/plan
LIVEOS_ISO_IMAGE := $(CACHE_DIR)/build_output/bootstrap.iso
LIVEOS_VM_IMAGE := $(CACHE_DIR)/providers/libvirt/vm_disks/bootstrap.qcow2

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
	$(TF_BIN) -chdir=$(SANDBOX_DIR) plan -var="cache_dir=$(CACHE_DIR)" -out $(TF_PLAN_SANDBOX)

dev.build: dev.init dev.validate dev.plan
	@echo "Setting up host system..."
	$(ANSIBLE_BIN) $(SANDBOX_DIR)/playbooks/host_pre.yaml --tags setup
	@echo "Converting live image to QCOW2..."
	qemu-img convert -f raw -O qcow2 -o preallocation=metadata,cluster_size=65536 $(LIVEOS_ISO_IMAGE) $(LIVEOS_ISO_IMAGE)
	@echo "Creating resources..."
	$(TF_BIN) -chdir=$(SANDBOX_DIR) apply -var="cache_dir=$(CACHE_DIR)" -auto-approve $(TF_PLAN_SANDBOX)
