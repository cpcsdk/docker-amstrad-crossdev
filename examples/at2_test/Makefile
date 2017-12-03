all: BUILD_DSK


DSK_FNAME=at2_test.dsk
LOAD_ADDRESS=x4000
EXECUTABLE=EXE

vpath %.asm src/ 


include CPC.mk


AKS_FILE=./data/A\ Harmless\ Grenade.aks
AKY_FILE=A\ Harmless\ Grenade.aky


$(AKY_FILE): $(AKS_FILE)
	$(call SONG_TO_AKY,$^,$@)


test.o: $(AKY_FILE)

$(EXECUTABLE): test.o
	$(call SET_HEADER,$^,$@,$(AMSDOS_BINARY),$(LOAD_ADDRESS),$(LOAD_ADDRESS))

$(DSK_FNAME):
	$(call CREATE_DSK,$(DSK_FNAME))

BUILD_DSK: $(EXECUTABLE) $(DSK_FNAME)
	$(call PUT_FILE_INTO_DSK,$(DSK_FNAME),$(EXECUTABLE))


clean:
	-rm *.o
	-rm *.exo
	-rm *.NOHEADER
	-rm *.lst
	-rm $(EXECUTABLE) $(AKY_FILE)

distclean: clean
	-rm $(DSK_FNAME)

launch: BUILD_DSK
	arnold $(DSK_FNAME)


launch_on_cpc: $(EXECUTABLE)
	$(call RUN_FILE_ON_CPC,$(EXECUTABLE))

test_from_host:
	./bootstrap.sh make
