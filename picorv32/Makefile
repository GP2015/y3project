PROGRAM = picorv32
ADDITIONAL_SOURCES = picorv32.v

include ../general.mk

FIRMWARE_DIR = $(BUILD_DIR)/firmware

$(FIRMWARE_DIR)/firmware.elf: blink.S
	mkdir -p $(FIRMWARE_DIR)
	riscv64-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -nostartfiles -Wl,-Ttext=0x0 -Wl,-e,_start -Wl,--no-relax -o $(FIRMWARE_DIR)/firmware.elf blink.S

$(FIRMWARE_DIR)/firmware.bin: $(FIRMWARE_DIR)/firmware.elf
	riscv64-elf-objcopy -O binary $(FIRMWARE_DIR)/firmware.elf $(FIRMWARE_DIR)/firmware.bin

$(FIRMWARE_DIR)/firmware.hex: $(FIRMWARE_DIR)/firmware.bin
	python3 bin2hex.py $< $@

build: $(FIRMWARE_DIR)/firmware.hex
