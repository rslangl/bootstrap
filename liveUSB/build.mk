.PHONY: live_os.clean live_os.build

CONTAINER_NAME := "liveos-builder"

live_os.clean:
	@echo "Cleanup live OS image build..."
	@if [ $$(docker ps -q -f name=$$CONTAINER_NAME) ]; then \
		docker stop $$CONTAINER_NAME; \
	fi; \
	if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^$$CONTAINER_NAME:"; then \
		docker rmi $$CONTAINER_NAME; \
	fi

live_os.copy_resources:
	@echo "Copying resources to live OS config directory..."
	cp $(RESOURCES_DIR)/images/* $(LIVE_OS_DIR)/config/hooks/includes.chroot/images/
	cp $(RESOURCES_DIR)/containers/* $(LIVE_OS_DIR)/config/hooks/includes.chroot/containers/

live_os.build_image: live_os.generate
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

