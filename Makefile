PYTHON3:=python3
TASS:=64tass
SHELLCMD:=$(PYTHON3) submodules/shellcmd.py/shellcmd.py
BUILD:=.build
BEEB_BUILD:=beeb/Z
RELEASE:=releases

##########################################################################
##########################################################################

.PHONY:all
all:
	$(SHELLCMD) mkdir "$(BUILD)"
	$(SHELLCMD) mkdir "$(BEEB_BUILD)"

	$(TASS) --case-sensitive --long-branch --m65xx --cbm-prg -L "$(BUILD)/6502-tests.lst" -o "$(BUILD)/6502-tests.prg" "6502-tests.s65"
	$(PYTHON3) submodules/beeb/bin/prg2bbc.py "$(BUILD)/6502-tests.prg" "$(BEEB_BUILD)/$$.TESTS"

	$(TASS) --case-sensitive --long-branch --m6502 --cbm-prg -L "$(BUILD)/6502-consistency-tests.lst" -o "$(BUILD)/6502-consistency-tests.prg" "6502-consistency-tests.s65"
	$(PYTHON3) submodules/beeb/bin/prg2bbc.py "$(BUILD)/6502-consistency-tests.prg" "$(BEEB_BUILD)/M.CONS"

	$(PYTHON3) submodules/beeb/bin/ssd_create.py -b '*RUN TESTS' -o "$(BUILD)/6502-tests.ssd" "$(BEEB_BUILD)/$$.TESTS"

##########################################################################
##########################################################################

.PHONY:clean
	$(SHELLCMD) rm-tree "$(BUILD)"
	$(SHELLCMD) rm-tree "$(BEEB_BUILD)"

##########################################################################
##########################################################################

.PHONY:release
release: TIMESTAMP:=$(shell $(SHELLCMD) strftime -d _ _Y_m_dT_H_M_S)
release: all
	$(SHELLCMD) mkdir "$(RELEASE)"
	$(SHELLCMD) copy-file "$(BUILD)/6502-tests.ssd" "$(RELEASE)/6502-tests.$(TIMESTAMP).ssd"
