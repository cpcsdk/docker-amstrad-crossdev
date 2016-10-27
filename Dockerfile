# The aim of this Dockerfile is to produce a
# docker machine able to manage Amstrad CPC projects.
# It mainly comes from a Makefile I maintened for such things
#
# It should be reconstructed from time to time as some tools
# evolve without changing their URL (vasm for example)


# Force Full rebuild 30/07/2016

FROM ubuntu:16.04
MAINTAINER Romain Giot <giot.romain@gmail.com>

# Ensemble of URL needed to install stuff
ENV VASM_URL  http://sun.hasenbraten.de/vasm/daily/vasm.tar.gz
ENV VLINK_URL  http://sun.hasenbraten.de/vlink/daily/vlink.tar.gz
ENV EXOMIZER_URL  http://hem.bredband.net/magli143/exo/exomizer209.zip
ENV LIBDSK_URL  http://www.seasip.info/Unix/LibDsk/libdsk-1.4.0.tar.gz
ENV INSTALLATION_BIN  /usr/local/bin
ENV HFE_URL svn://svn.code.sf.net/p/hxcfloppyemu/code/
ENV CPCTELERA_URL=https://github.com/lronaldo/cpctelera/archive/v1.4.tar.gz 

ENV TERM xterm-256color

ENV LIBDSK_HEADERS_DIR /usr/local/include/

ENV GENERAL_DEPENDENCIES \
		ack-grep \
		build-essential \
		cmake \
		cmake \
		curl \
		make \
		python \
		unzip \
		wget \
		wine 

ENV EDITOR_DEPENDENCIES\
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

ENV CPCTELERA_DEPENDENCIES \
	bison \
	flex \
	libboost-dev \
	libfreeimage-dev 
	

ENV GIT_SVN_DEPENDENCIES \
	git \
	gitg \
	meld \
	subversion

RUN mkdir /src /cpctelera

# install the set of dependencies
RUN apt-get update && \
	apt-get install -qy software-properties-common && \
	dpkg --add-architecture i386 && \
	add-apt-repository ppa:ubuntu-wine/ppa && \
	apt-get update && \
	apt-get upgrade -qy && \
	apt-get dist-upgrade -qy && \
	apt-get install  -qy \
		${GENERAL_DEPENDENCIES} \
		${EDITOR_DEPENDENCIES} \
		${CPCTELERA_DEPENDENCIES} \
		${GIT_SVN_DEPENDENCIES} && \
	apt-get purge -y software-properties-common && \
	apt-get autoclean -y &&\
	rm -rf /var/lib/apt/lists/*




# libdsk
WORKDIR /src
RUN wget ${LIBDSK_URL} -O- | \
	tar -xzf - && \
	cd libdsk-* && \
	./configure && \
	make -j2 && \
	make install && \
	rm -rf ../libdsk-*



# exomizer installation
WORKDIR /src
RUN wget ${EXOMIZER_URL} -O /tmp/exo.zip && \
	unzip /tmp/exo.zip -d exomizer && \
	rm /tmp/exo.zip && \
	cd exomizer/src && \
	sed -i -e 's/-mtune=i686//' Makefile && \
	make -j2 && \
	cp exoraw exomizer ${INSTALLATION_BIN} && \
	rm -rf ../../exomizer




# CPCSDK stuff
WORKDIR /src
RUN git clone --depth=1 https://github.com/cpcsdk/cpctools.git && \
	cd cpctools/cpctools && \
	sed -e '1i#include <cstdlib>' -i $LIBDSK_HEADERS_DIR/libdsk.h && \
	cmake -DLIBDSK_HEADERS_DIR=${LIBDSK_HEADERS_DIR}  . && \
	make createSnapshot && \
	cp tools/createSnapshot ${INSTALLATION_BIN} && \
	cd ../hideur_maikeur && \
	make -f Makefile-unix.eng ; \
	cp hideur ${INSTALLATION_BIN} && \
	cd ../iDSK && \
	cmake .  && \
	make -j2 iDSK && \
	cp iDSK ${INSTALLATION_BIN} && \
	cd ../cpctools/tools/AFT2 && \
	make aft2 && \
	cp aft2 ${INSTALLATION_BIN} && \
	cd ../damsConverter && \
	make damsConverter && \
	cp damsConverter ${INSTALLATION_BIN} && \
	cd ../../lib && \
	cp libcpc.so ${INSTALLATION_BIN}/../lib && \
	cd ../../.. && \
	rm -rf cpctools


# add cpctelera
WORKDIR /cpctelera
RUN wget ${CPCTELERA_URL} -O -| \
	tar -xzf - && \
	cd cpctelera-* && \
	./setup.sh

# add hfe creation
# Install additional tools (integrate with the original cpcsdk)
WORKDIR /src
RUN	svn checkout svn://svn.code.sf.net/p/hxcfloppyemu/code/ hxcfloppyemu-code && \
	cd hxcfloppyemu-code/HxCFloppyEmulator/build && \
	make ;  \
	cp hxcfe /usr/bin && \
	cp *.so /usr/lib && \
	rm -rf ../../../hxcfloppyemu-code

# Install pycpc
WORKDIR /src
RUN git clone https://github.com/cpcsdk/pycpcdemotools.git && \
	cd pycpcdemotools && \
	python setup.py install && \
	rm -rf ../pycpcdemotools


# vasm installation XXX sometimes need to update vasm when bugfixes are ready
WORKDIR /src
RUN wget ${VASM_URL} -O- | \
	tar -xzf - && \
	cd vasm && \
	make -j2 CPU=z80 SYNTAX=oldstyle && \
	cp vasmz80_oldstyle vobjdump ${INSTALLATION_BIN} && \
	rm -rf ../vasm


# vlink installation
WORKDIR /src
RUN wget ${VLINK_URL} -O- | \
	tar -xzf - && \
	cd vlink && \
	make -j2 && \
	cp vlink ${INSTALLATION_BIN} && \
	rm -rf ../vlink
	

# Remove all sources to reduce image size
RUN rm -rf /src

# Create the user of interest
RUN useradd \
	--home-dir /home/arnold \
	--create-home \
	--shell /bin/bash \
	arnold
RUN addgroup arnold dialout
USER arnold

RUN winecfg

# Install vim plugins
RUN mkdir -p ~/.vim/autoload ~/.vim/bundle && \
	curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim && \
	cd ~/.vim/bundle && \
	git clone --depth=1 https://github.com/majutsushi/tagbar && \
	git clone --depth=1 https://github.com/xolox/vim-misc.git && \
	git clone --depth=1 https://github.com/xolox/vim-easytags.git && \
	git clone --depth=1 https://github.com/altercation/vim-colors-solarized.git && \
	git clone --depth=1 https://github.com/cpcsdk/vim-z80-democoding.git


ADD bashrc /home/arnold/.bashrc
ADD vimrc /home/arnold/.vimrc
ADD ctags /home/arnold/.ctags

RUN git config --global merge.tool meld

# ensure the shell will properly work

# ensure X tools can be used

