FAMILY     = artix7
BOARD      = nexys_a7_100
DBPART     = xc7a100tcsg324
SPEEDGRADE = 1

BUILD_DIR = ../build/${PROGRAM}
CHIPDB = ../chipdb

PART = ${DBPART}-${SPEEDGRADE}
NEXTPNR_XILINX_DIR ?= /snap/openxc7/current/opt/nextpnr-xilinx
NEXTPNR_XILINX_PYTHON_DIR ?= ${NEXTPNR_XILINX_DIR}/python
PRJXRAY_DB_DIR ?= ${NEXTPNR_XILINX_DIR}/external/prjxray-db

${BUILD_DIR}/main.json: main.v ${ADDITIONAL_SOURCES}
	mkdir -p $(BUILD_DIR)
	yosys -p "synth_xilinx -flatten -abc9 ${SYNTH_OPTS} -arch xc7 -top main; write_json ${BUILD_DIR}/main.json" $< ${ADDITIONAL_SOURCES}

${CHIPDB}/${DBPART}.bin:
	mkdir -p ${CHIPDB}
	DIE=$$(echo ${PART} | sed -E 's/^(xc7z007s|xc7z012s|xc7z014s|xc7[azks][0-9]+t?|xc7vx[0-9]+t?).*/\1/'); \
	if [ "$$DIE" = xc7a35t ]; then DIE=xc7a50t; fi; \
	if [ "$$DIE" = xc7z007s ]; then DIE=xc7z010; fi; \
	python3 ${NEXTPNR_XILINX_DIR}/share/nextpnr/himbaechel/uarch/xilinx/gen/xilinx_gen.py \
	    --xray ${PRJXRAY_DB_DIR}/${FAMILY} --device $$DIE --bba ${CHIPDB}/${DBPART}.bba
	${NEXTPNR_XILINX_DIR}/bin/bbasm -l ${CHIPDB}/${DBPART}.bba ${CHIPDB}/${DBPART}.bin

${BUILD_DIR}/main.fasm: ${BUILD_DIR}/main.json ${CHIPDB}/${DBPART}.bin main.xdc
	nextpnr-xilinx --chipdb ${CHIPDB}/${DBPART}.bin --xdc main.xdc --json ${BUILD_DIR}/main.json --fasm $@ ${PNR_ARGS}
	
${BUILD_DIR}/main.bit: ${BUILD_DIR}/main.fasm
	fpga-as --prjxray_db_path=${PRJXRAY_DB_DIR}/${FAMILY} --part ${PART} $< > $@

build: ${BUILD_DIR}/main.bit

flash: ${BUILD_DIR}/main.bit
	openFPGALoader --board ${BOARD} --bitstream $<
