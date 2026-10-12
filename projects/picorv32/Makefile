.DEFAULT_GOAL := build
PROGRAM_NAME := picorv32
SRCS := $(wildcard $(CURDIR)/rtl/*.v)

include ../../config.mk

ASM_FILE := firmware/blink.S

FIRMWARE_DIR := $(BUILD_DIR)/${PROGRAM_NAME}/firmware
FIRMWARE_HEX := $(FIRMWARE_DIR)/firmware.hex

$(FIRMWARE_DIR)/firmware.elf: ${ASM_FILE}
	mkdir -p $(FIRMWARE_DIR)
	riscv64-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -nostartfiles -Wl,-Ttext=0x0 -Wl,-e,_start -Wl,--no-relax -o $@ $<

$(FIRMWARE_DIR)/firmware.bin: $(FIRMWARE_DIR)/firmware.elf
	riscv64-elf-objcopy -O binary $< $@

$(FIRMWARE_DIR)/firmware.hex: $(FIRMWARE_DIR)/firmware.bin
	python3 bin2hex.py $< $@

firmware.hex: $(FIRMWARE_DIR)/firmware.hex
	cp $< $@

.PHONY: build
build: firmware.hex

include ../../build.mk