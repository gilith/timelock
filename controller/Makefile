###############################################################################
# TIMELOCK CONTROLLER MAKEFILE
# Copyright (c) 2014 Joe Leslie-Hurd, distributed under the MIT license
###############################################################################

.SUFFIXES:

###############################################################################
# The default action.
###############################################################################

.PHONY: default
default: iverilog

###############################################################################
# Cleaning temporary files.
###############################################################################

TEMP = \
  *.out \
  *.o

.PHONY: clean
clean:
	@echo
	@echo '+------------------+'
	@echo '| Clean everything |'
	@echo '+------------------+'
	@echo
	rm -f $(TEMP)

###############################################################################
# Building using Icarus Verilog: http://iverilog.icarus.com/
###############################################################################

IVERILOG = iverilog

VVP = vvp

TARGETS = \
  controller_testbench.out

.PHONY: iverilog-info
iverilog-info:
	@echo
	@echo '+----------------------------------------+'
	@echo '| Build and test the timelock controller |'
	@echo '+----------------------------------------+'
	@echo

.PHONY: iverilog
iverilog: iverilog-info $(TARGETS)

controller_testbench.out: controller_testbench.o
	$(VVP) $< | tee $@

controller_testbench.o: controller_testbench.v controller.v ../montgomery/test_timelock_3.v ../uart/uart_receiver.v ../uart/uart_transmitter.v
	$(IVERILOG) -DSEED=$(shell date +%s) -o $@ $<
