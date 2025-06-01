RESOURCES_DIR := resources

export RESOURCES_DIR

include common/generate.mk

.PHONY: all clean

all: generate

clean: clean
