ROOT_DIR := $(CURDIR)
RESOURCES_DIR := $(ROOT_DIR)/resources
HOSTS_DIR := $(ROOT_DIR)/hosts

export ROOT_DIR
export RESOURCES_DIR
export HOSTS_DIR

include host_configs/generate.mk
include liveUSB/build.mk

define HELPTEXT
Usage: make <target>

Targets:
	help			Prints this help text
	generate	Generates necessary configurations
endef
export HELPTEXT

.PHONY: all clean

all: generate	# TODO: generate first, then build

help:
	@echo "$$HELPTEXT"

clean: clean
