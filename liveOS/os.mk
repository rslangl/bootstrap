.PHONY: os.clean os.build

REGISTRY_CONTAINERS := alpine
CONTAINER_NAME := "liveos-builder"

os.clean:
	@echo "Cleanup live OS image build..."
	@if [ $$(docker ps -q -f name=$$CONTAINER_NAME) ]; then \
		docker stop $$CONTAINER_NAME; \
	fi; \
	if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^$$CONTAINER_NAME:"; then \
		docker rmi $$CONTAINER_NAME; \
	fi

os.deb-fetch:
	@echo "Fetching apt repository packages..."
	docker build -t apt-deb-fetcher -f $(LIVE_BUILD_DIR)/docker/apt-deb-fetcher/Dockerfile $(LIVE_BUILD_DIR)/docker/apt-deb-fetcher
	docker run --rm \
		-v $(LIVE_BUILD_DIR)/build-artifacts/aptrepo/packages:/workdir/packages \
		-v $(LIVE_BUILD_DIR)/docker/apt-deb-fetcher/packages.txt:/workdir/packages.txt \
		apt-deb-fetcher

os.apt: os.deb-fetch
	@echo "Building apt repository..."
	docker build -t apt-repo-builder -f $(LIVE_BUILD_DIR)/docker/apt-repo-builder/Dockerfile $(LIVE_BUILD_DIR)/docker/apt-repo-builder
	docker run --rm -v $(LIVE_BUILD_DIR)/build-artifacts/aptrepo:/repo apt-repo-builder

os.img-fetch:
	@echo "Fetching container images..."
	docker run -d -p 5000:5000 --name local_registry registry:2
	for container in "${!REGISTRY_CONTAINERS[@]}"; do \
  	IFS="|" read -r name <<< "${REGISTRY_CONTAINERS[$container]}" \
	  docker pull "$container" \
  	docker tag "$container" "localhost:5000/$container" \
	  docker push "localhost:5000/$container" \
	done
	mkdir "${DOWNLOAD_DIR}/registry_data"
	docker stop registry

os.img: os.img-fetch
	@echo "Building container registry..."
	docker cp registry:/var/lib/registry -v $(PWD)/build-artifacts/registry_data
	docker save registry:2 -o $(PWD)/build-artifacts/registry.tar

os.tf:
	@echo "Fetching Terraform providers..."
	docker build -t tf-mirror -f $(LIVE_BUILD_DIR)/docker/tf-providers/Dockerfile $(LIVE_BUILD_DIR)/docker/tf-providers
	docker run --rm -v $(LIVE_BUILD_DIR)/build-artifacts/tf-providers:/mirror tf-mirror

os.build: os.apt os.img os.tf
	@echo "Copying resources to live OS image paths..."
	cp -r build-artifacts/aptrepo live-build/config/includes.chroot/srv/
	cp -r build-artifacts/registry_data live-build/config/includes.chroot/srv/
	cp -r build-artifacts/registry.tar live-build/config/includes.chroot/srv/
	cp -r build-artifacts/tf-providers live-build/config/includes.chroot/srv
	@echo "Building live OS image..."
	docker build -t $(CONTAINER_NAME) .
	@echo "Running live OS image..."
	docker run --rm -it --name $(CONTAINER_NAME) \
  --privileged \
  --cap-add=SYS_ADMIN \
  --security-opt seccomp=unconfined \
  -v "$(CURDIR)/config":/home/builder/config \
  -v "$(CURDIR)/output":/home/builder/output \
  -v "$(CURDIR)/build.sh":/home/builder/build.sh \
  $(CONTAINER_NAME) ./build.sh

