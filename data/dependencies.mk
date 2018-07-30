# XXX Raspian version is incomplete and only contians the minimal tools

VASM_URL?=http://server.owl.de/~frank/tags/vasm1_8c.tar.gz
VLINK_URL?=http://sun.hasenbraten.de/vlink/daily/vlink.tar.gz
EXOMIZER_URL?=https://bitbucket.org/magli143/exomizer/wiki/downloads/exomizer-2.0.11.zip
LIBDSK_URL=http://www.seasip.info/Unix/LibDsk/libdsk-1.4.0.tar.gz
HFE_URL=svn://svn.code.sf.net/p/hxcfloppyemu/code/
CPCTELERA_URL?=https://github.com/lronaldo/cpctelera/archive/v1.4.2.zip
CPCSDK_URL=https://github.com/cpcsdk/cpctools.git 
IDSK_URL=https://github.com/cpcsdk/idsk.git
HIDEUR_MAKER_URL=https://github.com/cpcsdk/hideur_maikeur.git
GFX2CRTC_URL=git@github.com:cpcsdk/gfx2crtc.git
ARNOLD_URL=http://cpctech.cpc-live.com/arnoldsrc.zip
ARNOLD_SHA1SUM=ae736bd73a379471d3b23b30ae685ba1157d0ce1
TOCDT_URL=http://cpctech.cpc-live.com/download/2cdt.zip
PLAYTZX_URL=https://github.com/ralferoo/cpctools.git
CPCXFER_URL=https://github.com/M4Duke/cpcxfer.git
CPCXFS_URL=http://cpctech.cpc-live.com/download/cpcxfs.zip
GRAFX2_URL=https://gitlab.com/GrafX2/grafX2.git

INSTALLATION_BIN=/usr/local/bin
LIBDSK_HEADERS_DIR=/usr/local/include/

CPCTELERA_DIR?=/usr/local/cpctelera# Folder where to install CPC telera stuff
SRC_DIR?=/src# Source folder where to download all applications




GENERAL_DEPENDENCIES=\
		bc \
		bless \
		build-essential \
		cloc \
		cmake \
		cmake \
		curl \
		make \
		python \
		python3-pil \
		python-matplotlib \
		silversearcher-ag \
		sudo \
		unzip \
		wget \
		libncurses5-dev libncursesw5-dev
#		wine64 # XXX not added in raspbian container

HXC_DEPENDENCIES=\
		 libftdi1 \
		 libftdi-dev 

EDITOR_DEPENDENCIES=\
	exuberant-ctags \
	libcanberra-gtk-module  \
	powerline \
	vim-ctrlp \
	vim-fugitive \
	vim-gnome \
	vim-pathogen \
	vim-syntastic \
	vim-ultisnips \
	vim-youcompleteme \

CPCTELERA_DEPENDENCIES=\
	bison \
	flex \
	g++ \
	gcc \
	libboost-dev \
	libfreeimage-dev \
	mono-complete \
	unzip \
	wget


GIT_SVN_DEPENDENCIES=\
	git \
	gitg \
	meld \
	subversion

GRAFX2_DEPENDENCIES=\
		    libsdl-image1.2-dev\
		    libsdl-image1.2 \
		    libsdl-ttf2.0-dev \
		    libsdl-ttf2.0-0 \
		    libfltk1.3-dev libfltk1.3 libfltk1.3-compat-headers \
		    libfontconfig1-dev liblua5.1-dev lua5.1 pkgconf   fontconfig


CPCXFS_DEPENDENCIES=libncurses5-dev

# XXX Attention, some dependencies are related to the developmenet on Arnold, not its construction
ARNOLD_DEPENDENCIES=\
	libsdl-image1.2 libsdl1.2-dev libsdl1.2debian \
	libwxbase3.0-0v5 libwxbase3.0-dev libwxgtk3.0-0v5 libwxgtk3.0-dev wx3.0-headers \
	fossil \
	pasmo



# install the set of dependencies
install_dependencies:
	DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install  -qq -y --allow-unauthenticated --no-upgrade --show-progress \
				$(GENERAL_DEPENDENCIES) \
				$(GIT_SVN_DEPENDENCIES) 
	touch $@




.PHONY:build_dirs
build_dirs:
	mkdir -p $(SRC_DIR) $(CPCTELERA_DIR)



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


# The containter stuff does not work properly when host user has not id 1000.
# The aim of this rule is to install a soft that fixes that
install_user_managment:
	#gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
	curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.10/gosu-$$(dpkg --print-architecture)" \
	    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.10/gosu-$$(dpkg --print-architecture).asc" \
	    && chmod +x /usr/local/bin/gosu
	    #&& gpg --verify /usr/local/bin/gosu.asc \
	    #&& rm /usr/local/bin/gosu.asc \


.PHONY: setup
setup: build_dirs install_dependencies install_libdsk install_user_managment


