.PHONY: dev.clean dev.build

TF_PLAN_SANDBOX := $(CACHE_DIR)/tfdata/modules/sandbox/plan
LIVE_SYSTEM_ISO := $(CACHE_DIR)/build_output/bootstrap.iso
LIVE_SYSTEM_VM_DISK := $(CACHE_DIR)/providers/libvirt/vm_disks/bootstrap.qcow2

dev.clean:
	@echo "Destroying resources..."
	terraform -chdir=$(SANDBOX_DIR) destroy -auto-approve
	@echo "Resetting host system..."
	ansible-playbook $(SANDBOX_DIR)/playbooks/host_pre.yaml --tags teardown

dev.init:
	@echo "Initializing Terraform..."
	terraform -chdir=$(SANDBOX_DIR) init -upgrade

dev.validate: dev.init
	tflint --chdir=$(SANDBOX_DIR)
	terraform -chdir=$(SANDBOX_DIR) validate

dev.plan: dev.validate
	@echo "Planning with ISO at $(ISO_ABS_PATH)..."
	terraform -chdir=$(SANDBOX_DIR) plan -var="cache_dir=$(CACHE_DIR)" -out $(TF_PLAN_SANDBOX)

dev.build: dev.init dev.validate dev.plan
	@echo "Setting up host system..."
	ansible-playbook $(SANDBOX_DIR)/playbooks/host_pre.yaml --tags setup
	@echo "Converting live image to QCOW2..."
	qemu-img convert -f raw -O qcow2 -o preallocation=metadata,cluster_size=65536 $(LIVE_SYSTEM_ISO) $(LIVE_SYSTEM_ISO)
	@echo "Creating resources..."
	terraform -chdir=$(SANDBOX_DIR) apply -var="cache_dir=$(CACHE_DIR)" -auto-approve $(TF_PLAN_SANDBOX)
