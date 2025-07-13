.PHONY: live_os.clean live_os.build

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
	docker build -t apt-deb-fetcher docker/apt-deb-fetcher
	docker run --rm \
		-v $(PWD)/build-artifacts/aptrepo/packages:/workdir/packages \
		-v $(PWD)/docker/apt-deb-fetcher/packages.txt:/workdir/packages.txt \
		apt-deb-fetcher

os.apt: os.deb-fetch
	@echo "Building apt repository..."
	docker build -t apt-repo-builder docker/apt-repo-builder/Dockerfile
	docker run --rm -v $(PWD)/build-artifacts/aptrepo:/repo apt-repo-builder

# os.copy_resources:
# 	@echo "Copying resources to live OS config directory..."
# 	cp $(RESOURCES_DIR)/images/* $(LIVE_OS_DIR)/config/hooks/includes.chroot/images/
# 	cp $(RESOURCES_DIR)/containers/* $(LIVE_OS_DIR)/config/hooks/includes.chroot/containers/

os.build: os.apt
	@echo "Copying resources to live OS image paths..."
	cp -r build-artifacts/aptrepo live-build/config/includes.chroot/srv/
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

