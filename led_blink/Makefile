FAMILY     = artix7
BOARD      = nexys_a7_100
DBPART     = xc7a100tcsg324
SPEEDGRADE = 1
PROGRAM    = led_blink

PART = ${DBPART}-${SPEEDGRADE}
NEXTPNR_XILINX_DIR ?= /snap/openxc7/current/opt/nextpnr-xilinx
NEXTPNR_XILINX_PYTHON_DIR ?= ${NEXTPNR_XILINX_DIR}/python
PRJXRAY_DB_DIR ?= ${NEXTPNR_XILINX_DIR}/external/prjxray-db

build/${PROGRAM}.json: ${PROGRAM}.v ${ADDITIONAL_SOURCES}
	yosys -p "synth_xilinx -flatten -abc9 ${SYNTH_OPTS} -arch xc7 -top ${PROGRAM}; write_json build/${PROGRAM}.json" $< ${ADDITIONAL_SOURCES}

chipdb/${DBPART}.bin:
	pypy3 ${NEXTPNR_XILINX_PYTHON_DIR}/bbaexport.py --device ${PART} --bba chipdb/${DBPART}.bba
	bbasm -l chipdb/${DBPART}.bba chipdb/${DBPART}.bin
	rm chipdb/${DBPART}.bba

build/${PROGRAM}.fasm: build/${PROGRAM}.json chipdb/${DBPART}.bin ${PROGRAM}.xdc
	nextpnr-xilinx --chipdb chipdb/${DBPART}.bin --xdc ${PROGRAM}.xdc --json build/${PROGRAM}.json --fasm $@ ${PNR_ARGS}
	
build/${PROGRAM}.frames: build/${PROGRAM}.fasm
	fasm2frames --part ${PART} --db-root ${PRJXRAY_DB_DIR}/${FAMILY} $< > $@

build/${PROGRAM}.bit: build/${PROGRAM}.frames
	xc7frames2bit --part_file ${PRJXRAY_DB_DIR}/${FAMILY}/${PART}/part.yaml --part_name ${PART} --frm_file $< --output_file $@

build: build/${PROGRAM}.bit

flash: build/${PROGRAM}.bit
	openFPGALoader --board ${BOARD} --bitstream $<
