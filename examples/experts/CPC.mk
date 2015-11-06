######################################################
# Common Makefile instruction for building CPC demos #
######################################################

#BUG Current limitation: may only work with powershell/github client


# TODO clean this file and create one file specific to Linux and one file specific to windows

#The aim of this configuration file is to write portable things.
# Tools can be different between linux and windows
#TODO write function to put and remove files from dsk

ifdef SystemRoot
   RM = del /Q
   FixPath = $(subst /,\,$1)
   AWK=..\wintools\awk.exe
   DIFF=..\wintools\diff.exe
   $(warning 'Hello Voxy/ELiot')
else
   ifeq ($(shell uname), Linux)
      RM = rm -f
      FixPath = $1
      AWK='awk'
      PATH := ../bin/:$(PATH)
      DIFF=diff
   endif
endif


# Assembler name. Can be vasmz80_oldstyle or sjasmplus2
ifdef SystemRoot
ASSEMBLER=..\wintools\vasmz80_oldstyle.exe
else
ASSEMBLER?=vasmz80_oldstyle
endif

# Compressor name. Only exomizer for the moment
ifdef SystemRoot
COMPRESS=..\wintools\exomizer.exe
else
COMPRESS=exomizer
endif


ifdef SystemRoot
SNA_MANAGER=..\wintools\createSnapshot.exe
else
SNA_MANAGER=createSnapshot
SNA_MANAGER=wine ../wintools/createSnapshot.exe
endif

ifdef SystemRoot
ADD_BRK_TO_SNA=..\commontools\BRK2SNA.exe
else
ADD_BRK_TO_SNA=../commontools/BRK2SNA.exe
endif
# DSK manipulation tool. Only iDSK for the moment.
# Other tools may be usefull.
# TODO make the thing work also under windows
#
ifdef SystemRoot
	DSKTOOL=..\wintools\iDSK
	SHELL=cmd
else
	DSKTOOL?=iDSK
endif
# Tool to add header on file. :http://downwater.free.fr/?rubrique=utilitaires
HIDEUR=hideur
SHELL=/bin/sh

.SUFFIXES: .asm, .o, .exo
VPATH= src

# Assemble a file
# ###############

#TODO build here a .lst file compatbile between vasm and sjasmplus
%.o %.lst: %.asm
# Assemble using sjamsplus2 (private assembler based on sjasm)
ifeq (, $(findstring WINDOWS,$(PATH)))
	@echo -e '\033[0;34m\033[1mCompile \033[4m$<\033[0m\033[1m\033[0;34m\033[1m to \033[4m$@\033[0m \033[0m'
endif
ifneq (, $(findstring sjasmplus2,$(ASSEMBLER)))
	$(ASSEMBLER) --inc=src --sym=$(notdir $(<:.asm=.sym)) --lst=$(notdir $(<:.asm=.lst)) --raw=$@ $<  > compilation.log && exit 0; \
	cat compilation.log ; \
       	rm $@; \
	exit 255
 endif
# Assembling using vasm
 ifneq (, $(findstring vasmz80,$(ASSEMBLER)))
	$(ASSEMBLER) $(ASMFLAGS) -esc -L $(notdir $(<:.asm=.lst))  -Fbin -o $*.o $< > compilation.log && exit 0; \
		cat compilation.log ; \
		 rm $@ ; \
	     exit 255
  ifneq (, $(findstring WINDOWS,$(PATH)))
	$(ASSEMBLER)  $(ASMFLAGS) -Ftest -o  $*.lst $<
  endif
 endif


# Build a complete list of symbols when required
# ONLY works with Powershell :(
# tools are installed with github application
%.sym: %.lst
ifdef SystemRoot
	sed $^ -e 's/.*EXPR(.*).*//'  \
	       -e 's/ \*.*\*.*//' \
		   -e 's/.*:.*//' \
		   -e "s/^ \([^ ]*\) \([^ ]*\) LAB (\(.*\)).*/\1.\2 equ \3/" \
		   -e 's/^\([^ ]*\) LAB (\(.*\)).*/\1 equ \2/'  | \
	       grep equ | sort | uniq > $@
else
	echo 'Gest symbols'
	vasm_symbols.py  $^  > $@
endif
#-e "s/^ \([^ ]*\) \([^ ]*\) LAB (\([^ ]*\)).*/\1.\2 equ \3/" 

# Compress a file (with literals)
#################
ifdef SystemRoot
COMPRESS_FILE = $(COMPRESS) raw -o $(2) $(1) 
else
COMPRESS_FILE = @echo "\033[0;32m\033[1mCompress \033[4m$(1)\033[0m\033[1m\033[0;32m\033[1m to \033[4m$(2)\033[0m"; \
		$(COMPRESS) raw  -o $(2) $(1)  > /dev/null;
endif

%.exo: %.o
	$(call COMPRESS_FILE,$<,$@)

%.exo: %.bin
	$(call COMPRESS_FILE,$<,$@)


# Amsdos file management
########################

#
# AMsdos file types
AMSDOS_BASIC=0
AMSDOS_ENCRYPTED_BASIC=1
AMSDOS_BINARY=2

# Macro to extract a file from a DSK
# Usage $(call GET_FILE_FROM_DSK, dsk, file)
GET_FILE_FROM_DSK = @echo '\033[1mExtract $(2) from $(1)\033[0m'; \
		    $(DSKTOOL) $(1) -g $(2) 2> /dev/null > /dev/null;

# Macro to create a new DSK
# Usage $(call CREATE_DSK, dsk)
ifdef SystemRoot
CREATE_DSK =  $(DSKTOOL) $(1) -n 
else
CREATE_DSK = echo "\033[1mBuild DSK $(1)\033[0m"; \
	     $(DSKTOOL) $(1) -n > /dev/null 2>/dev/null;
endif

# Macro to put a file into a DSK
# header must be set
# Usage $(call PUT_FILE_INTO_DSK, dsk, file)
ifdef SystemRoot
PUT_FILE_INTO_DSK = ../wintools/CPCDiskXP -File $(2) -AddToExistingDsk $(1)
else
PUT_FILE_INTO_DSK = echo "\033[0;35m\033[1mAdd $(2) to $(1)\033[0m" ; \
		    $(DSKTOOL) $(1) -i $(2) -f 2> /dev/null > /dev/null;
endif




# Macro set a header to a file
##############################
#
# Usage: $(call SET_HEADER, source, destination, type, load, exec)
# load and exec are called like xffff and xffff
# TODO test for other type of files !
ifdef SystemRoot
SET_HEADER=copy $(1) $(2) && ..\wintools\CPCDiskXP.exe -File $(2) -AddAmsdosHeader $(subst x,,$(4)) -AmsdosEntryAddress $(subst x,,$(5))
else
SET_HEADER = echo '\033[0;31m\033[1mSet header to \033[4m$(1)\033[0m'; \
	     $(HIDEUR) $(1) -o $(2) -t $(3) -l $(4) -x $(5) 2> /dev/null  > /dev/null;
endif

# Launch AFT
############
AFT:
ifndef SystemRoot
	sudo chmod a+rw /dev/ttyUSB0
	-rm  ~/.wine/dosdevices/com1
	-ln -s /dev/ttyUSB0 ~/.wine/dosdevices/com1
endif
	../wintools/Aft.exe


AFT_BLUETOOTH:
ifndef SystemRoot
	sudo chmod a+rw /dev/rfcomm0
	-ln -s /dev/rfcomm0 ~/.wine/dosdevices/com2
endif
	../wintools/Aft.exe /2


# Launch Windows Virtual Machine which contains Winape
####

ifndef SystemRoot
VM_NAME=Windaube
START_VBOX:
	vboxmanage showvminfo $(VM_NAME)  | grep running || vboxmanage startvm $(VM_NAME)
endif

