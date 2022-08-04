PYTHON3:=python3
TASS:=64tass
SHELLCMD:=$(PYTHON3) submodules/shellcmd.py/shellcmd.py
BUILD:=.build
BEEB_BUILD:=beeb/Z

##########################################################################
##########################################################################

.PHONY:all
all:
	$(SHELLCMD) mkdir $(BUILD)
	$(SHELLCMD) mkdir $(BEEB_BUILD)


	$(TASS) --case-sensitive --long-branch --m6502 --cbm-prg -L "$(BUILD)/6502-tests.lst" -o "$(BUILD)/6502-tests.prg" "6502-tests.s65"
	$(PYTHON3) submodules/beeb/bin/prg2bbc.py --io "$(BUILD)/6502-tests.prg" "$(BEEB_BUILD)/$$.TESTS"

##########################################################################
##########################################################################

.PHONY:clean
	$(SHELLCMD) rm-tree $(BUILD)
	$(SHELLCMD) rm-tree $(BEEB_BUILD)
