# Installations scripts / Must be run as root


# 2017-05-19: Rebuild because of vasm update / fix pycpcdemotools .

VASM_URL?=http://server.owl.de/~frank/tags/vasm1_8.tar.gz
VLINK_URL?=http://sun.hasenbraten.de/vlink/daily/vlink.tar.gz
EXOMIZER_URL?=http://hem.bredband.net/magli143/exo/exomizer209.zip
LIBDSK_URL=http://www.seasip.info/Unix/LibDsk/libdsk-1.4.0.tar.gz
HFE_URL=svn://svn.code.sf.net/p/hxcfloppyemu/code/
CPCTELERA_URL?=https://github.com/lronaldo/cpctelera/archive/v1.4.tar.gz 
CPCSDK_URL=https://github.com/cpcsdk/cpctools.git 
IDSK_URL=https://github.com/cpcsdk/idsk.git
HIDEUR_MAKER_URL=https://github.com/cpcsdk/hideur_maikeur.git
GFX2CRTC_URL=git@github.com:cpcsdk/gfx2crtc.git
ARNOLD_URL=http://cpctech.cpc-live.com/arnoldsrc.zip
ARNOLD_SHA1SUM=ae736bd73a379471d3b23b30ae685ba1157d0ce1
TOCDT_URL=http://cpctech.cpc-live.com/download/2cdt.zip
PLAYTZX_URL=https://github.com/ralferoo/cpctools.git
CPCXFER_URL=https://github.com/M4Duke/cpcxfer.git

INSTALLATION_BIN=/usr/local/bin
LIBDSK_HEADERS_DIR=/usr/local/include/

CPCTELERA_DIR?=/usr/local/cpctelera # Folder where to install CPC telera stuff
SRC_DIR?=/src # Source folder where to download all applications


GENERAL_DEPENDENCIES=\
		ack-grep \
		bc \
		build-essential \
		cmake \
		cmake \
		cloc \
		curl \
		make \
		python \
		python-matplotlib \
		unzip \
		wget \
		wine64

HXC_DEPENDENCIES=\
		 libftdi-dev \
		 libftdi1 

EDITOR_DEPENDENCIES=\
	exuberant-ctags \
	libcanberra-gtk-module  \
	powerline \
	vim-ctrlp \
	vim-fugitive \
	vim-gnome \
	vim-syntastic \
	vim-ultisnips \
	vim-youcompleteme \
  	vim-fugitive

CPCTELERA_DEPENDENCIES=\
	bison \
	flex \
	libboost-dev \
	libfreeimage-dev 
	

GIT_SVN_DEPENDENCIES=\
	git \
	gitg \
	meld \
	subversion

# XXX Attention, some dependencies are related to the developmenet on Arnold, not its construction
ARNOLD_DEPENDENCIES=\
	libsdl-image1.2 libsdl1.2-dev libsdl1.2debian \
	libwxbase3.0-0v5 libwxbase3.0-dev libwxgtk3.0-0v5 libwxgtk3.0-dev wx3.0-headers \
	fossil \
	pasmo


.PHONY:install_all
install_all: 
	$(MAKE) build_dirs
	$(MAKE) install_dependencies
	$(MAKE) install_libdsk
	$(MAKE) -j $$(nproc) install_exomizer \
		install_cpcsdk \
		install_cpctelera \
		install_hfestuff \
		install_pycpc \
		install_vasm \
		install_vlink \
		install_arnold_and_deps \
		install_cpcxfer
	rm -rf $(SRC_DIR)
	#$(MAKE) install_winape


quick_test:
	$(MAKE) build_dirs
	$(MAKE) install_dependencies
	$(MAKE) install_cpcxfer

.PHONY:build_dirs
build_dirs:
	mkdir -p $(SRC_DIR) $(CPCTELERA_DIR)


# install the set of dependencies
install_dependencies:
	apt-get update && apt-get install -q -y --no-upgrade software-properties-common && add-apt-repository ppa:saiarcot895/myppa && apt-get update && apt-get -y install -qy --no-upgrade apt-fast 
	apt-fast update && \
		apt-fast install  -q -y --allow-unauthenticated --no-upgrade --show-progress \
			$(GENERAL_DEPENDENCIES) \
			$(EDITOR_DEPENDENCIES) \
			$(CPCTELERA_DEPENDENCIES) \
			$(HXC_DEPENDENCIES) \
			$(GIT_SVN_DEPENDENCIES) \
			$(ARNOLD_DEPENDENCIES) && \
		apt-get purge -y software-properties-common && \
		apt-get autoclean -y &&\
		rm -rf /var/lib/apt/lists/*
	touch $@



install_cpcxfer:
	cd $(SRC_DIR) && git clone $(CPCXFER_URL) && cd cpcxfer && \
	make && cp xfer /usr/local/bin && \
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



# libdsk
install_libdsk:
	cd $(SRC_DIR) && \
	wget $(LIBDSK_URL) -O- | \
		tar -xzf - && \
		cd libdsk-* && \
		./configure && \
		make -j2 && \
		make install && \
		rm -rf ../libdsk-*
	touch $@



# exomizer installation
install_exomizer:
	cd $(SRC_DIR) && \
		wget $(EXOMIZER_URL) -O /tmp/exo.zip && \
		unzip /tmp/exo.zip -d exomizer && \
		rm /tmp/exo.zip && \
		cd exomizer/src && \
		sed -i -e 's/-mtune=i686//' Makefile && \
		make -j2 && \
		cp exoraw exomizer $(INSTALLATION_BIN) && \
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
	wget ${CPCTELERA_URL} -O -| \
	tar -xzf - && \
	cd cpctelera-* && \
	./setup.sh
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
	touch $@




