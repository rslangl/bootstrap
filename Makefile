# Specify commonly used variables for paths
ROOT_DIR := $(CURDIR)
HOSTS_CONFIG_DIR := $(ROOT_DIR)/host_configs
RESOURCES_DIR := $(ROOT_DIR)/resources
HOSTS_DIR := $(ROOT_DIR)/hosts
SBIN_DIR := $(ROOT_DIR)/sbin

# Export common vars for use in sub-targets
export ROOT_DIR
export RESOURCES_DIR
export HOSTS_DIR

# Include Makefiles from relevant subdirectories
include host_configs/generate.mk
include liveUSB/os.mk

# Helptext for whenever I sperg out too much
define HELPTEXT
Usage: make <target>

Targets:
	help			Prints this help text
	generate	Generates necessary configurations
endef
export HELPTEXT

.PHONY: all clean fetch_resources

all: build

help:
	@echo "$$HELPTEXT"

clean: host_configs.clean os.clean

fetch_resources:
	@echo "Fetching resources: ISO images"
	bash $(SBIN_DIR)/fetch_iso.sh
	@echo "Fetching resources: Docker containers"
	bash $(SBIN_DIR)/fetch_container.sh
	@echo "Fetching resources: Tools"
	bash $(SBIN_DIR)/fetch_tools.sh

build: fetch_resources host_configs.generate os.build
