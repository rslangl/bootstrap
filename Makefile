# Specify commonly used variables for paths
ROOT_DIR := $(CURDIR)
SANDBOX_DIR := $(ROOT_DIR)/sandbox
CACHE_DIR := $(ROOT_DIR)/.cache
LIVE_SYSTEM_DIR := $(ROOT_DIR)/live_system

# Export common vars for use in sub-targets
export ROOT_DIR
export SANDBOX_DIR
export CACHE_DIR
export LIVE_SYSTEM_DIR

# Include Makefiles from relevant subdirectories
include sandbox/dev.mk
include live_system/os.mk

# Helptext for whenever I sperg out too much
define HELPTEXT
Usage: make <target>

Targets:
	help			Prints this help text
	clean			Cleans build cache, inlcuding downloaded resources
	resources	Downloads resources required for the build process
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

clean: dev.clean os.clean

# TODO
# resources:

dev: dev.build

build: os.build

validate: dev.validate os.validate
