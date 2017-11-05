######################################################
# Common Makefile instruction for building CPC demos #
######################################################

#BUG Current limitation: may only work with powershell/github client


# TODO clean this file and create one file specific to Linux and one file specific to windows

#The aim of this configuration file is to write portable things.
# Tools can be different between linux and windows
#TODO write function to put and remove files from dsk


# Possible variables: exomizer/aplib
COMPRESS_WITH?=exomizer


RM = rm -f
FixPath = $1
AWK='awk'
PATH := ./bin/:../30yo/bin:$(PATH)
DIFF=diff


ASSEMBLER?=vasmz80_oldstyle
HXC_CONVERTER?=hxcfe


# Compressor configuration
ifeq ($(COMPRESS_WITH), exomizer)
  COMPRESS=exomizer
endif
ifeq ($(COMPRESS_WITH), aplib)
  COMPRESS=wine-development ./tools/appack.exe
endif




SNA_MANAGER=createSnapshot

ADD_BRK_TO_SNA=../commontools/BRK2SNA.exe

DSKTOOL?=iDSK

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
	@echo -e '\033[0;34m\033[1mCompile \033[4m$<\033[0m\033[1m\033[0;34m\033[1m to \033[4m$@\033[0m \033[0m'
ifneq (, $(findstring sjasmplus2,$(ASSEMBLER)))
	$(ASSEMBLER) --inc=src --sym=$(notdir $(<:.asm=.sym)) --lst=$(notdir $(<:.asm=.lst)) --raw=$@ $<  > compilation.log && exit 0; \
	cat compilation.log ; \
       	rm $@; \
	exit 255
 endif
# Assembling using vasm
 ifneq (, $(findstring vasmz80,$(ASSEMBLER)))
	$(ASSEMBLER) $(ASMFLAGS) -L $(notdir $(<:.asm=.lst))  -Fbin -o $*.o $< > compilation.log && exit 0; \
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
	vasm_symbols.py  $^  > $@

# Compress a file
#################
ifeq ($(COMPRESS_WITH), exomizer)
  COMPRESS_FILE = echo "\033[0;32m\033[1mCompress \033[4m$(1)\033[0m\033[1m\033[0;32m\033[1m to \033[4m$(2)\033[0m"; \
		$(COMPRESS) raw -c -o $(2) $(1)  > /dev/null;
endif

ifeq ($(COMPRESS_WITH), aplib)
  COMPRESS_FILE = echo "\033[0;32m\033[1mCompress \033[4m$(1)\033[0m\033[1m\033[0;32m\033[1m to \033[4m$(2)\033[0m"; \
		$(COMPRESS) $(1) $(2) ;
endif



%.exo: %.o
	$(call COMPRESS_FILE,$<,$@)
%.exo: %.bin
	$(call COMPRESS_FILE,$<,$@)
%.exo: %
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
GET_FILE_FROM_DSK = echo '\033[1mExtract $(2) from $(1)\033[0m'; \
		    $(DSKTOOL) $(1) -g $(2) ;

# Macro to create a new DSK
# Usage $(call CREATE_DSK, dsk)
CREATE_DSK = iDSK $(1) -n > /dev/null 2>/dev/null

# Macro to put a file into a DSK
# header must be set
# Usage $(call PUT_FILE_INTO_DSK, dsk, file)
PUT_FILE_INTO_DSK =  iDSK $(1) -i $(2) -f 2> /dev/null > /dev/null


# Convert a dsk in hfe
CREATE_HFE = $(HXC_CONVERTER) -finput:$(1) -foutput:$(2) -conv:HXC_HFE
%.hfe: %.dsk
	$(call CREATE_HFE,$^,$@)

# Macro set a header to a file
##############################
#
# Usage: $(call SET_HEADER, source, destination, type, load, exec)
# load and exec are called like xffff and xffff
# TODO test for other type of files !
SET_HEADER = echo '\033[0;31m\033[1mSet header to \033[4m$(1)\033[0m'; \
	     $(HIDEUR) $(1) -o $(2) -t $(3) -l $(4) -x $(5) 


# Remove the header of an AMSDOS file
REMOVE_HEADER = dd if=$(1) of=$(1).NOHEADER bs=128 skip=1

%.NOHEADER: %
	$(call REMOVE_HEADER,$^)

# Macro to call damsConverter
DAMS_CONVERTER = damsConverter $(1) $(2)


#
# M4 - CPCWIFI

XFER?=/usr/local/bin/xfer
CPCIP?=192.168.1.26
RUN_FILE_ON_CPC = $(XFER) -y $(CPCIP) $(1) 


# Launch AFT
############
AFT:
	aft2


###################
# Arkos Tracker 2 #
###################

define SONG_TO_AKY
	SongToAky --sourceProfile z80  "$(1)" "$(2)"
endef

%.aky: %.aks
	$(call SONG_TO_AKY,$^,$@)

%.aky: %.sks
	$(call SONG_TO_AKY,$^,$@)

%.aky: %.wyz
	$(call SONG_TO_AKY,$^,$@)
