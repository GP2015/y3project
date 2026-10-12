FAMILY     := artix7
BOARD      := nexys_a7_100
DBPART     := xc7a100tcsg324
SPEEDGRADE := 1

PART := ${DBPART}-${SPEEDGRADE}

NEXTPNR_XILINX_DIR ?= /snap/openxc7/current/opt/nextpnr-xilinx
NEXTPNR_XILINX_PYTHON_DIR ?= ${NEXTPNR_XILINX_DIR}/python
PRJXRAY_DB_DIR ?= ${NEXTPNR_XILINX_DIR}/external/prjxray-db

ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
BUILD_DIR := ${ROOT_DIR}/build
CHIPDB_DIR := ${ROOT_DIR}/chipdb
XDC_FILE := ${ROOT_DIR}/constraints.xdc

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

${CHIPDB_DIR}/${DBPART}.bin:
	mkdir -p ${CHIPDB_DIR}
	DIE=$$(echo ${PART} | sed -E 's/^(xc7z007s|xc7z012s|xc7z014s|xc7[azks][0-9]+t?|xc7vx[0-9]+t?).*/\1/'); \
		if [ "$$DIE" = xc7a35t ]; then DIE=xc7a50t; fi; \
		if [ "$$DIE" = xc7z007s ]; then DIE=xc7z010; fi; \
		python3 ${NEXTPNR_XILINX_DIR}/share/nextpnr/himbaechel/uarch/xilinx/gen/xilinx_gen.py --xray ${PRJXRAY_DB_DIR}/${FAMILY} --device $$DIE --bba ${CHIPDB_DIR}/${DBPART}.bba
	${NEXTPNR_XILINX_DIR}/bin/bbasm -l ${CHIPDB_DIR}/${DBPART}.bba $@
	rm -f ${CHIPDB_DIR}/${DBPART}.bba
