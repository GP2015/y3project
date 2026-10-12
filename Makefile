.DEFAULT_GOAL := build_all

PJ ?= "NA"

include config.mk

PROJECTS := $(patsubst projects/%/Makefile,%,$(wildcard projects/*/Makefile))

.PHONY: build_all
build_all: $(PROJECTS)

.PHONY: $(PROJECTS)
$(PROJECTS):
	@echo "Building $@"
	$(MAKE) -C projects/$@

.PHONY: flash
flash:
	$(MAKE) -C projects/${PJ} flash

.PHONY: clean
clean:
	rm -rf build/
