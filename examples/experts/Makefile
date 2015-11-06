# Automatic building of the demo
# Krusty/Benediction 2011
# modification in 2015 in order to test docker

include CPC.mk

.SILENT:

#############
# Constants #
#############
# DSK
DSK = 'experts_bugfixed.dsk'
IMG_SOURCE=data/img_center.png

# Adresses of bootstrap
BOOTSTRAP_LOAD=x500
BOOTSTRAP_EXEC=x500

vpath %.asm 	src/ 

.SUFFIXES: .asm, .o, .exo, .cre

vpath %.o .
vpath %.exo .
vpath %.cre .

.PHONY: ALL

data/%.EXO: data/%.AYC
	$(call COMPRESS_FILE,$<,$@)

#picture.o: $(IMG_SOURCE)
#	./tools/fontcatcher $(IMG_SOURCE) picture.o 32 1
	
#image_colors.asm: $(IMG_SOURCE)
#	python tools/get_palette_from_png.py $(IMG_SOURCE) > $@

data/liner.dat: data/liner.txt
	cat $^ | tr '[:lower:]' '[:upper:]' | python tools/transform_text_to_bytes.py data/font_corres.txt > $@

plasma.o: data/image.bin src/transition.asm src/writer.asm data/liner.dat
bootloader.o: plasma.exo data/MCKLAIN2.EXO data/COUNT.EXO src/deexo.asm

#######
# DSK #
#######

read.me: readme.o
	@$(call SET_HEADER, $<, $@, $(AMSDOS_BINARY), x9000, x9000)

experts.bin: bootloader.o
	@$(call SET_HEADER, $<, $@, $(AMSDOS_BINARY), $(BOOTSTRAP_LOAD), $(BOOTSTRAP_EXEC))

FILES_TO_PUT= data/readme.bas experts.bin

ALL: $(FILES_TO_PUT)
	@$(MAKE) check
	@test -e $(DSK) || $(call CREATE_DSK, $(DSK))
	@$(foreach file, $(FILES_TO_PUT), \
		$(call PUT_FILE_INTO_DSK, $(DSK), $(file)) )

#############
# Utilities #
# ###########
.PHONY: clean distclean check
check:
	#bash ./tools/check_source_validity.sh || ($(MAKE) clean ; exit 1)
clean:
	-rm *.o 
	-rm *.bin
	-rm *.exo
	-rm *.lst
	-find . -name "*.sym" -delete
	-rm data/MCKLAIN2.EXO data/COUNT.EXO

distclean: clean
	-rm $(DSK)


zip: ALL
	zip "experts_(Benediction_KOD_Overlanders_2011)_music_bugs_fixed.zip " $(DSK) screenshots/les_experts_coutances.png file.idz
