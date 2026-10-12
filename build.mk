include $(dir $(realpath $(lastword $(MAKEFILE_LIST))))/config.mk

OUT_DIR := ${BUILD_DIR}/${PROGRAM_NAME}

.PHONY: build
build: ${OUT_DIR}/top.bit

.PHONY: flash
flash: build
	openFPGALoader --board ${BOARD} --bitstream ${OUT_DIR}/top.bit

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

${OUT_DIR}/top.json: ${SRCS}
	mkdir -p $(OUT_DIR)
	yosys -p "synth_xilinx -flatten -abc9 ${SYNTH_OPTS} -arch xc7 -top top; write_json $@" $^

${OUT_DIR}/top.fasm: ${OUT_DIR}/top.json ${CHIPDB_DIR}/${DBPART}.bin ${XDC_FILE}
	nextpnr-xilinx --chipdb ${CHIPDB_DIR}/${DBPART}.bin --xdc ${XDC_FILE} --json $< --fasm $@ ${PNR_ARGS}

${OUT_DIR}/top.bit: ${OUT_DIR}/top.fasm
	fpga-as --prjxray_db_path=${PRJXRAY_DB_DIR}/${FAMILY} --part ${PART} $< > $@
