.PHONY: default
default: help

#----------------------------------------------------------------------------
# export CDS_LIC_FILE := <license server> # UPDATEME
#----------------------------------------------------------------------------
# export AMSHOME := <path to XCELIUM> # UPDATEME
export PATH    := $(AMSHOME)/tools/inca/bin:$(AMSHOME)/tools/bin:$(PATH)
export PATH=/Cadence/XCELIUM2409/tools/bin:$PATH

#----------------------------------------------------------------------------
RTL_DIR=$(PWD)/../../rtl
BIN_DIR=$(PWD)/../bin
PROBE_DIR=$(PWD)/../probe

#----------------------------------------------------------------------------
xrun: # Run simulation
	cp ${PROBE_DIR}/probe.tcl .
	xrun -f ${BIN_DIR}/xrunArgs.f

	xrun -f hms_args.f

#----------------------------------------------------------------------------
simv: # Open SimVision GUI
	simvision waves.shm &

#----------------------------------------------------------------------------
clean: # Clean
	rm -rf *.log xcelium.d xrun.history xrun.key .simvision *.diag probe.tcl waves.shm xmprotect.log

#----------------------------------------------------------------------------
help: # show help for each of the Makefile recipes.
	@grep -E '^[a-zA-Z0-9_-]+:.*?# .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?# "}; {printf "\033[36m%-20s|\033[0m %s\n", $$1, $$2}'
