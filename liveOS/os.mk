.PHONY: os.clean os.build

REGISTRY_CONTAINERS := alpine
CONTAINER_NAME := "liveos-builder"

os.clean:
	# @echo "Cleanup live OS image build..."
	# @if [ $$(docker ps -q -f name=$$CONTAINER_NAME) ]; then \
	# 	docker stop $$CONTAINER_NAME; \
	# fi; \
	# if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^$$CONTAINER_NAME:"; then \
	# 	docker rmi $$CONTAINER_NAME; \
	# fi
	@echo "Destroying resources..."
	terraform -chdir=$(SANDBOX_DIR) destroy -auto-approve

# os.deb-fetch:
# 	@echo "Fetching apt repository packages..."
# 	docker build -t apt-deb-fetcher -f $(LIVE_BUILD_DIR)/docker/apt-deb-fetcher/Dockerfile $(LIVE_BUILD_DIR)/docker/apt-deb-fetcher
# 	docker run --rm \
# 		-v $(LIVE_BUILD_DIR)/build-artifacts/aptrepo/packages:/workdir/packages \
# 		-v $(LIVE_BUILD_DIR)/docker/apt-deb-fetcher/packages.txt:/workdir/packages.txt \
# 		apt-deb-fetcher

os.apt: #os.deb-fetch
	@echo "Building apt resources..."
	# docker build -t apt-repo-builder -f $(LIVE_BUILD_DIR)/docker/apt-repo-builder/Dockerfile $(LIVE_BUILD_DIR)/docker/apt-repo-builder
	# docker run --rm -v $(LIVE_BUILD_DIR)/build-artifacts/aptrepo:/repo apt-repo-builder
	terraform apply -var="build-apt=true" -var="build_bsd=false" -var="build_registry=false"

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
	terraform apply -var="build-apt=false" -var="build_bsd=false" -var="build_registry=true"

# os.tf:
# 	@echo "Fetching Terraform providers..."
# 	docker build -t tf-mirror -f $(LIVE_BUILD_DIR)/docker/tf-providers/Dockerfile $(LIVE_BUILD_DIR)/docker/tf-providers
# 	docker run --rm -v $(LIVE_BUILD_DIR)/build-artifacts/tf-providers:/mirror tf-mirror
# 	docker container stop local_registry && docker container rm local_registry

os.init:
	@echo "Initializing terraform..."
	terraform init -chdir=$(LIVEOS_DIR) init

os.validate: os.init
	tflint --chdir=$(LIVEOS_DIR)
	terraform -chdir=$(LIVEOS_DIR) validate

os.plan: os.validate
	terraform -chir=$(LIVEOS_DIR) plan -out $(TF_PLAN)

os.build: os.init os.validate os.plan 
	# @echo "Copying resources to live OS image paths..."
	# cp -r build-artifacts/aptrepo live-build/config/includes.chroot/srv/
	# cp -r build-artifacts/registry_data live-build/config/includes.chroot/srv/
	# cp -r build-artifacts/registry/registry.tar live-build/config/includes.chroot/srv/
	# cp -r build-artifacts/tf-providers live-build/config/includes.chroot/srv
	# @echo "Building live OS image..."
	# docker build -t $(CONTAINER_NAME) .
	# @echo "Running live OS image..."
	# docker run --rm -it --name $(CONTAINER_NAME) \
	#  --privileged \
	#  --cap-add=SYS_ADMIN \
	#  --security-opt seccomp=unconfined \
	#  -v "$(CURDIR)/config":/home/builder/config \
	#  -v "$(CURDIR)/output":/home/builder/output \
	#  -v "$(CURDIR)/build.sh":/home/builder/build.sh \
	#  $(CONTAINER_NAME) ./build.sh
	@echo "Building live OS image..."
	terraform -chdir=$(LIVEOS_DIR) apply -auto-approve $(TF_PLAN)
