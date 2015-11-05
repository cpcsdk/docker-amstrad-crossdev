# The aim of this Dockerfile is to produce a
# docker machine able to manage Amstrad CPC projects.
# It mainly comes from a Makefile I maintened for such things
#
# It should be reconstructed from time to time as some tools
# evolve without changing their URL (vasm for example)


FROM ubuntu:15.10
MAINTAINER Romain Giot <giot.romain@gmail.com>

# Ensemble of URL needed to install stuff
ENV VASM_URL  http://sun.hasenbraten.de/vasm/release/vasm.tar.gz
ENV VLINK_URL  http://sun.hasenbraten.de/vlink/daily/vlink.tar.gz
ENV EXOMIZER_URL  http://hem.bredband.net/magli143/exo/exomizer209.zip
ENV LIBDSK_URL  http://www.seasip.info/Unix/LibDsk/libdsk-1.3.8.tar.gz
ENV INSTALLATION_BIN  /usr/local/bin

RUN mkdir /src

# install the set of dependencies
RUN apt-get update && \
	apt-get install  -qy \
		wget \
		build-essential \
		make \
		python \
		git \
		cmake \
		unzip




# libdsk
WORKDIR /src
RUN wget ${LIBDSK_URL} -O- | \
	tar -xzf - && \
	cd libdsk-1.3.8 && \
	./configure && \
	make -j2 && \
	make install


# vasm installation
WORKDIR /src
RUN wget ${VASM_URL} -O- | \
	tar -xzf - && \
	cd vasm && \
	make -j2 CPU=z80 SYNTAX=oldstyle && \
	cp vasmz80_oldstyle vobjdump ${INSTALLATION_BIN}


# vlink installation
WORKDIR /src
RUN wget ${VLINK_URL} -O- | \
	tar -xzf - && \
	cd vlink && \
	make -j2 && \
	cp vlink ${INSTALLATION_BIN}
	


# exomizer installation
WORKDIR /src
RUN wget ${EXOMIZER_URL} -O /tmp/exo.zip && \
	unzip /tmp/exo.zip -d exomizer && \
	rm /tmp/exo.zip && \
	cd exomizer/src && \
	sed -i -e 's/-mtune=i686//' Makefile && \
	make -j2 && \
	cp exoraw exomizer ${INSTALLATION_BIN}




# CPCSDK stuff
WORKDIR /src
env LIBDSK_HEADERS_DIR /usr/local/include/
RUN git clone --depth=1 https://github.com/cpcsdk/cpctools.git && \
	cd cpctools/cpctools && \
	sed -e '1i#include <cstdlib>' -i $LIBDSK_HEADERS_DIR/libdsk.h && \
	cmake -DLIBDSK_HEADERS_DIR=${LIBDSK_HEADERS_DIR}  .


# createSnapshot
WORKDIR /src/cpctools/cpctools
RUN make createSnapshot && \
	cp tools/createSnapshot ${INSTALLATION_BIN}

# hideur
WORKDIR /src/cpctools/hideur_maikeur
RUN make -f Makefile-unix.eng ; \
	cp hideur ${INSTALLATION_BIN}

# iDSK
WORKDIR /src/cpctools/iDSK
RUN cmake .  && \
	make -j2 iDSK && \
	cp iDSK ${INSTALLATION_BIN}


# git stuff
RUN apt-get install -y meld
RUN git config --global merge.tool meld

# add cpctelera
WORKDIR /src
RUN apt-get install -y libboost-dev libfreeimage-dev bison flex
RUN wget https://github.com/lronaldo/cpctelera/archive/v1.2.3.zip -O /tmp/cpctelera.zip && \
	unzip /tmp/cpctelera.zip && \
	rm /tmp/cpctelera.zip && \
	cd cpctelera-1.2.3 && \
	./setup.sh


# Create the user of interest
RUN useradd \
	--home-dir /home/arnold \
	--create-home \
	--shell /bin/bash \
	arnold
USER arnold
ADD .bashrc /home/arnold/


# ensure the shell will properly work
ENV TERM xterm-256color

