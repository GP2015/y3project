# -- Variables --

FAMILY := artix7
BOARD := nexys_a7_100
DBPART := xc7a100tcsg324
SPEEDGRADE := 1

PART := ${DBPART}-${SPEEDGRADE}

NEXTPNR_XILINX_DIR ?= /snap/openxc7/current/opt/nextpnr-xilinx
NEXTPNR_XILINX_PYTHON_DIR ?= ${NEXTPNR_XILINX_DIR}/python
PRJXRAY_DB_DIR ?= ${NEXTPNR_XILINX_DIR}/external/prjxray-db

ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
BUILD_DIR := ${ROOT_DIR}build
CHIPDB_DIR := ${ROOT_DIR}chipdb

CONSTRAINTS_FILE := ${ROOT_DIR}/gateware/constraints.xdc
BIN2HEX_FILE := ${ROOT_DIR}scripts/bin2hex.py
LINKER_FILE := ${ROOT_DIR}firmware/link.x

VERILOG_SRCS := $(wildcard ${ROOT_DIR}/gateware/rtl/*.v)

FIRMWARE_SRCS := $(shell find ${ROOT_DIR}/firmware -type f)
FIRMWARE_CRATES := led_inc switches pitch
FIRMWARE_BIN_FILES := $(addprefix ${BUILD_DIR}/,$(addsuffix .bin,${FIRMWARE_CRATES}))
FIRMWARE_HEX_FILES := $(addprefix ${BUILD_DIR}/,$(addsuffix .hex,${FIRMWARE_CRATES}))

.SECONDARY: ${FIRMWARE_BIN_FILES}

# -- Create Folders --

${BUILD_DIR}:
	mkdir -p ${BUILD_DIR}

${CHIPDB_DIR}:
	mkdir -p ${CHIPDB_DIR}


# -- Generate ChipDB --

${CHIPDB_DIR}/${DBPART}.bba: | ${CHIPDB_DIR}
	DIE=$$(echo ${PART} | sed -E 's/^(xc7z007s|xc7z012s|xc7z014s|xc7[azks][0-9]+t?|xc7vx[0-9]+t?).*/\1/'); \
		if [ "$$DIE" = xc7a35t ]; then DIE=xc7a50t; fi; \
		if [ "$$DIE" = xc7z007s ]; then DIE=xc7z010; fi; \
		python3 ${NEXTPNR_XILINX_DIR}/share/nextpnr/himbaechel/uarch/xilinx/gen/xilinx_gen.py --xray ${PRJXRAY_DB_DIR}/${FAMILY} --device $$DIE --bba ${CHIPDB_DIR}/${DBPART}.bba

${CHIPDB_DIR}/${DBPART}.bin: ${CHIPDB_DIR}/${DBPART}.bba
	${NEXTPNR_XILINX_DIR}/bin/bbasm -l $< $@


# -- Generate firmware --

${BUILD_DIR}/%.bin: ${FIRMWARE_SRCS} | ${BUILD_DIR}
	cd $(ROOT_DIR)/firmware/$* && \
		RUSTFLAGS="-C link-arg=-T${LINKER_FILE}" \
		cargo objcopy --bin=$* --release --target=riscv32i-unknown-none-elf -- -O binary $@

${BUILD_DIR}/%.hex: ${BUILD_DIR}/%.bin
	python3 ${BIN2HEX_FILE} $< $@


# -- Generate Verilog code --

${BUILD_DIR}/top.json: ${FIRMWARE_HEX_FILES} ${VERILOG_SRCS} | ${BUILD_DIR}
	yosys -p "synth_xilinx -flatten -abc9 ${SYNTH_OPTS} -arch xc7 -top top; write_json $@" ${VERILOG_SRCS}

${BUILD_DIR}/top.fasm: ${BUILD_DIR}/top.json ${CHIPDB_DIR}/${DBPART}.bin ${CONSTRAINTS_FILE}
	nextpnr-xilinx --chipdb ${CHIPDB_DIR}/${DBPART}.bin --xdc ${CONSTRAINTS_FILE} --json $< --fasm $@ ${PNR_ARGS}

${BUILD_DIR}/top.bit: ${BUILD_DIR}/top.fasm
	fpga-as --prjxray_db_path=${PRJXRAY_DB_DIR}/${FAMILY} --part ${PART} $< > $@


# -- Explicit recipes --

.PHONY: build
build: ${FIRMWARE_HEX_FILES} ${BUILD_DIR}/top.bit

.PHONY: flash
flash: build
	openFPGALoader --board ${BOARD} --bitstream ${BUILD_DIR}/top.bit

.PHONY: flashf
flashf: build
	openFPGALoader --board ${BOARD} -f --bitstream ${BUILD_DIR}/top.bit

.PHONY: clean
clean:
	rm -rf build/ target/
