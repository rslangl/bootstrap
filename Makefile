# Specify commonly used variables for paths
ROOT_DIR := $(CURDIR)
SANDBOX_DIR := $(ROOT_DIR)/sandbox
HOSTS_CONFIG_DIR := $(ROOT_DIR)/configs
CACHE_DIR := $(ROOT_DIR)/.cache
TOOLS_DIR := $(CACHE_DIR)/tools/amd64
HOSTS_DIR := $(ROOT_DIR)/hosts
LIVEOS_DIR := $(ROOT_DIR)/liveOS
SBIN_DIR := $(ROOT_DIR)/sbin

# Export common vars for use in sub-targets
export ROOT_DIR
export SANDBOX_DIR
export RESOURCES_DIR
export LIVEOS_DIR
export CACHE_DIR
export TOOLS_DIR
export HOSTS_DIR

# Include Makefiles from relevant subdirectories
include configs/config.mk
include sandbox/dev.mk
include liveOS/os.mk

# Helptext for whenever I sperg out too much
define HELPTEXT
Usage: make <target>

Targets:
	help			Prints this help text
	clean			Cleans build cache, inlcuding downloaded resources
	generate	Generates necessary configurations
	validate	Runs validation checks on the various subdirectories
	build			Builds the live OS image
	dev				Creates the sandbox environment locally
endef
export HELPTEXT

.PHONY: all clean resources

all: build

help:
	@echo "$$HELPTEXT"

clean: cfg.clean dev.clean os.clean

resources:
	@echo "Fetching resources: ISO images"
	bash $(SBIN_DIR)/get_iso_images.sh
	@echo "Fetching resources: Containers"
	bash $(SBIN_DIR)/get_containers.sh
	@echo "Fetching resources: Tools"
	bash $(SBIN_DIR)/get_tools.sh

generate: cfg.generate

dev: cfg.generate dev.build

build: cfg.generate os.build

validate: cfg.validate dev.validate os.validate
