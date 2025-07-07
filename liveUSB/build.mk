.PHONY: clean build

CONTAINER_NAME := "liveos-builder"

clean:
	@echo "Cleanup live OS image build..."
	-docker image rm -f $(CONTAINER_NAME)

build:
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

