RESOURCES_DIR := resources

export RESOURCES_DIR

include host_configs/generate.mk

.PHONY: all clean

all: generate

clean: clean
