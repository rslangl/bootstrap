
HOSTS := router

OUT_DIR = ./out

.PHONY: all clean

all: $(HOSTS)

clean:
	rm -rf $(OUT_DIR)

$(HOSTS):
	kcl run $@.k --output $(OUT_DIR)/$@.yaml

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

$(HOSTS): | $(OUT_DIR)
