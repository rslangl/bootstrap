.PHONY: os.clean os.build

TF_PLAN := $(CACHE_DIR)/tfstate/liveos/plan

os.clean:
	@echo "Destroying resources..."
	terraform -chdir=$(LIVEOS_DIR) destroy -auto-approve

os.apt:
	@echo "Building apt resources..."
	terraform  -chdir=$(LIVEOS_DIR) apply -auto-approve

# os.img-fetch:
# 	@echo "Fetching container images..."
# 	docker run -d -p 5000:5000 --name local_registry registry:2
# 	@for c in $(REGISTRY_CONTAINERS); do \
# 	  docker pull "$$c"; \
#   	docker tag "$$c" "localhost:5000/$$c"; \
# 	  docker push "localhost:5000/$$c"; \
# 	done

os.reg: #os.img-fetch
	@echo "Building container registry..."
	# docker cp local_registry:/var/lib/registry $(LIVE_BUILD_DIR)/build-artifacts/registry-data
	# docker save registry:2 -o $(LIVE_BUILD_DIR)/build-artifacts/registry/registry.tar
	terraform -chdir=$(LIVEOS_DIR) apply -auto-approve

# os.tf:
# 	@echo "Fetching Terraform providers..."
# 	docker build -t tf-mirror -f $(LIVE_BUILD_DIR)/docker/tf-providers/Dockerfile $(LIVE_BUILD_DIR)/docker/tf-providers
# 	docker run --rm -v $(LIVE_BUILD_DIR)/build-artifacts/tf-providers:/mirror tf-mirror
# 	docker container stop local_registry && docker container rm local_registry

os.init:
	@echo "Initializing terraform..."
	terraform -chdir=$(LIVEOS_DIR) init -upgrade

os.validate: os.init
	tflint --chdir=$(LIVEOS_DIR)
	terraform -chdir=$(LIVEOS_DIR) validate

os.plan: os.validate
	terraform -chdir=$(LIVEOS_DIR) plan -var="cache_dir=$(CACHE_DIR)" -var="scripts_dir=$(SBIN_DIR)" -out $(TF_PLAN)

os.build: os.init os.validate os.plan 
	# @echo "Copying resources to live OS image paths..."
	# cp -r build-artifacts/aptrepo live-build/config/includes.chroot/srv/
	# cp -r build-artifacts/registry_data live-build/config/includes.chroot/srv/
	# cp -r build-artifacts/registry/registry.tar live-build/config/includes.chroot/srv/
	# cp -r build-artifacts/tf-providers live-build/config/includes.chroot/srv
	@echo "Building live OS image..."
	terraform -chdir=$(LIVEOS_DIR) apply -auto-approve -var="cache_dir=$(CACHE_DIR)" -var="scripts_dir=$(SBIN_DIR)" $(TF_PLAN)
