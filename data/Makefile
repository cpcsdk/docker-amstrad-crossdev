# Installations scripts / Must be run as root

# 2018-05-12: Add SugarConvDsk
# 2017-11-05: Add Arkos Tracker
# 2017-10-25: Add Grafx2
# 2017-05-19: Rebuild because of vasm update / fix pycpcdemotools .

include dependencies.mk

NPROCS=1
#NPROCS=$(shell, nproc)

.PHONY:install_all
install_all:
	#$(MAKE) install_z80tonops # unique target when testing stuff
	$(MAKE) -j $(NPROCS) \
		install_chipnsfx \
		install_cpcxfs \
		install_exomizer \
		install_cpcsdk \
		install_pycpc \
		install_vasm \
		install_vlink \
		install_cpcxfer \
		install_at2 \
		install_z80tonops
	rm -rf $(SRC_DIR)
	#$(MAKE) install_winape


install_sugarconvdsk:
	cd $(SRC_DIR) && git clone https://github.com/Tom1975/SugarConvDsk.git
	cd $(SRC_DIR)/Sugar*/SugarConvDsk && \
		cmake . && \
		make -j8 && \
		ls && \
		cp SugarConvDsk /usr/local/bin && \
		rm -rf Sugar*

install_chipnsfx:
	cd $(SRC_DIR) && wget http://cngsoft.no-ip.org/chipnsfx-20180505.zip
	cd $(SRC_DIR) && unzip chipnsfx-*.zip
	mkdir -p /opt/chipnsfx
	cd /opt/chipnsfx && unzip $(SRC_DIR)/chipnsfx*.zip
	rm $(SRC_DIR)/chipnsfx*.zip
	echo 'wineconsole /opt/chipnsfx/CHIPNSFX.EXE $$*' > /usr/local/bin/chipnsfx
	chmod +x /usr/local/bin/chipnsfx


install_z80tonops:
	cd $(SRC_DIR) && git clone https://github.com/cpcsdk/z80tonops.git
	cd $(SRC_DIR) && cd z80tonops/src && cmake . && make install
	cd $(SRC_DIR) && rm -rf z80tonops

quick_test:
	$(MAKE) build_dirs
	$(MAKE) install_dependencies
	$(MAKE) install_cpcxfer


# deactivated / seems to not compile ...
install_grafx2:
	#cd $(SRC_DIR) && git clone $(GRAFX2_URL)
	#cd $(SRC_DIR) && cd grafX2/src && make install prefix=/usr
	#cd $(SRC_DIR) && rm -rf grafX2


install_cpcxfer:
	cd $(SRC_DIR) && git clone $(CPCXFER_URL) && cd cpcxfer && \
	gcc *.c -o xfer -O2 && cp xfer /usr/local/bin && \
	cp pyxfer.py /usr/local/bin && \
	cd .. && rm -rf cpcxfer

install_arnold_and_deps:
	cd $(SRC_DIR) && wget $(TOCDT_URL) -O 2cdt.zip && \
    unzip 2cdt.zip && \
    cd 2cdt && \
    make 2cdt && \
    cp 2cdt /usr/local/bin && \
		cd .. && \
		rm -rf 2cdt*
	cd $(SRC_DIR) && git clone --depth 1 $(PLAYTZX_URL) ralferoo && \
    cd ralferoo/playtzx-0.12b && \
    ./configure && \
    make install
	cd $(SRC_DIR) && \
		wget $(ARNOLD_URL) && \
		test "$$(sha1sum arnoldsrc.zip | cut -f1 -d' ')" !=  "$(ARNOLD_SHA1SUM)"
	cd $(SRC_DIR) && \
		unzip arnoldsrc.zip && \
		cd src && \
		find . -name "*.sh" -exec chmod +x \{\} \; &&  \
		mv ./cpc/EmuDevice.h  ./cpc/emudevice.h && \
	  ./make_arnz80_release.sh && \
		mkdir -p /opt/ && \
		cp -R ../exe/Release/arnold /opt/arnoldemu


install_cpcxfs:
	cd $(SRC_DIR) && wget $(CPCXFS_URL) -O cpcxfs.zip && \
	unzip cpcxfs.zip && \
	cd cpcxfs/src && \
	make -f makefile.lnx clean && \
	make -f makefile.lnx && \
	cp cpcxfs /usr/local/bin && \
	cd $(SRC_DIR) && rm -rf cpcxfs*




# exomizer installation
install_exomizer:
	cd $(SRC_DIR) && \
		wget $(EXOMIZER_URL) -O /tmp/exo.zip && \
		unzip /tmp/exo.zip -d exomizer && \
		rm /tmp/exo.zip && \
		cd exomizer/src && \
		sed -i -e 's/-mtune=i686//' Makefile && \
		make -j2 && ls && \
		cp exobasic exomizer $(INSTALLATION_BIN) && \
		rm -rf ../../exomizer
	touch $@




# CPCSDK stuff
install_cpcsdk:
	cd $(SRC_DIR) && \
	git clone --depth=1 $(CPCSDK_URL) && \
	cd cpctools/cpctools && \
	sed -e '1i#include <cstdlib>' -i $(LIBDSK_HEADERS_DIR)/libdsk.h && \
	cmake -DLIBDSK_HEADERS_DIR=$(LIBDSK_HEADERS_DIR)  . && \
	make createSnapshot && \
	cp tools/createSnapshot $(INSTALLATION_BIN) && \
	cd ../cpctools/tools/AFT2 && \
	make aft2 && \
	cp aft2 $(INSTALLATION_BIN) && \
	cd ../damsConverter && \
	make damsConverter && \
	cp damsConverter $(INSTALLATION_BIN) && \
	cd ../../lib && \
	cp libcpc.so $(INSTALLATION_BIN)/../lib && \
	cd ../../.. && \
	rm -rf cpctools
	git clone --depth=1 $(HIDEUR_MAKER_URL)
	cd hideur_maikeur && \
	make -f Makefile-unix.eng ; \
	cp hideur $(INSTALLATION_BIN) && \
	cd .. && \
	rm -rf hideur_maikeur
	git clone --depth=1 $(IDSK_URL) && \
	cd idsk && \
	cmake .  && \
	make -j2 iDSK && \
	cp iDSK $(INSTALLATION_BIN) && \
	cd .. && \
	rm -rf iDSK
	touch $@


# add cpctelera
install_cpctelera:
	cd $(CPCTELERA_DIR) && \
	wget ${CPCTELERA_URL} -O cpctelera.zip && \
	unzip cpctelera.zip && \
	cd cpctelera-* && \
	./setup.sh && \
	cd .. && rm cpctelera.zip
	touch $@

# add hfe creation
install_hfestuff:
	cd $(SRC_DIR) && \
	svn checkout $(HFE_URL) hxcfloppyemu-code && \
	cd hxcfloppyemu-code/HxCFloppyEmulator/build && \
	make ;  \
	cp hxcfe $(INSTALLATION_BIN) && \
	cp *.so $(INSTALLATION_BIN)/../lib && \
	rm -rf ../../../hxcfloppyemu-code
	touch $@

# Install pycpc
install_pycpc:
	cd $(SRC_DIR) && \
	git clone https://github.com/cpcsdk/pycpcdemotools.git && \
	cd pycpcdemotools && \
	python setup.py install && \
	rm -rf ../pycpcdemotools
	touch $@


install_vasm:
	cd $(SRC_DIR) && \
	wget $(VASM_URL) -O- | \
	tar -xzf - && \
	cd vasm && \
	make -j2 CPU=z80 SYNTAX=oldstyle && \
	cp vasmz80_oldstyle vobjdump $(INSTALLATION_BIN) && \
	rm -rf ../vasm
	touch $@


# vlink installation
install_vlink:
	cd $(SRC_DIR) && \
	wget $(VLINK_URL) -O- | \
	tar -xzf - && \
	cd vlink && \
	make -j2 && \
	cp vlink $(INSTALLATION_BIN) && \
	rm -rf ../vlink
	touch $@
	




# Add winape
install_winape:
	mkdir -p /winape && cd /winape && wget http://winape.net/download/WinAPE20B2.zip && unzip WinAPE20B2.zip && ls -R
	-xvfb-run -a wine start "FAIL" #ensure wine configuration is done. Note that this call will obviously fail
	touch $@


install_at2:
	mkdir -p /opt/ && cd /opt/ && \
		wget "http://www.julien-nevo.com/arkostracker/release/linux64/Arkos%20Tracker%202%20Linux64.zip" && \
		unzip *.zip && rm *.zip



