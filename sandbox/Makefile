# Relative path to ISO (within project structure)
ISO_REL_PATH := ../images/opnsense.iso
# Resolve absolute path using Make's built-in function
ISO_ABS_PATH := $(abspath $(ISO_REL_PATH))
# Terraform plan file
TF_PLAN := plan

# Terraform commands
.PHONY: init plan apply destroy validate

init:
	@echo "Initializing Terraform..."
	terraform init

plan:
	@echo "Planning with ISO at $(ISO_ABS_PATH)..."
	terraform plan -var="opnsense_iso_path=$(ISO_ABS_PATH)" -out $(TF_PLAN)

apply:
	@echo "Applying with ISO at $(ISO_ABS_PATH)..."
	terraform apply -auto-approve -var="opnsense_iso_path=$(ISO_ABS_PATH)" $(TF_PLAN)

destroy:
	@echo "Destroying resources..."
	terraform destroy -auto-approve -var="opnsense_iso_path=$(ISO_ABS_PATH)"

validate:
	terraform validate

show-path:
	@echo "Relative ISO path: $(ISO_REL_PATH)"
	@echo "Absolute ISO path: $(ISO_ABS_PATH)"

