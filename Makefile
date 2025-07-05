RESOURCES_DIR := resources

export RESOURCES_DIR

include host_configs/generate.mk

define HELPTEXT
Usage: make <target>

Targets:
	help			Prints this help text
	generate	Generates necessary configurations
endef
export HELPTEXT

.PHONY: all clean

all: generate

help:
	@echo "$$HELPTEXT"

clean: clean
