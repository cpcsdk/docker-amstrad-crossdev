# The aim of this Dockerfile is to produce a
# docker machine able to manage Amstrad CPC projects.
# It mainly comes from a Makefile I maintened for such things
#
# It should be reconstructed from time to time as some tools
# evolve without changing their URL (vasm for example)


FROM ubuntu:17.10
MAINTAINER Romain Giot <giot.romain@gmail.com>

ENV TERM xterm-256color

RUN rm -rf /var/lib/apt/lists/* && apt-get clean && apt-get update && apt-get install -qy make

# Prepare construction
RUN mkdir /cpcsdk
WORKDIR /cpcsdk
ADD data/dependencies.mk /cpcsdk/dependencies.mk
RUN make -f /cpcsdk/dependencies.mk setup

# build all the tools downloaded from the net
ADD data/Makefile /cpcsdk/Makefile
RUN make install_all


# Compile rasm that is embeded in the data
ADD data/rasm /tmp/rasm/
WORKDIR /tmp/rasm
RUN gcc *.c -o /usr/local/bin/rasm -lm
WORKDIR /cpcsdk
RUN rm -rf /tmp/rasm

# AFT version for the cpc booster
ADD data/minibooster/aft /usr/local/bin/aft-minibooster
RUN chmod +x /usr/local/bin/aft-minibooster

# Prepare the configuration files for Arnold user that is created on the fly when using container
RUN mkdir -p /home/arnold

# Install vim plugins
RUN mkdir -p /home/arnold/.vim/autoload /home/arnold/.vim/bundle && \
	cd /home/arnold/.vim/bundle && \
	git clone --depth=1 https://github.com/majutsushi/tagbar && \
	git clone --depth=1 https://github.com/xolox/vim-misc.git && \
	git clone --depth=1 https://github.com/xolox/vim-easytags.git && \
	git clone --depth=1 https://github.com/altercation/vim-colors-solarized.git && \
	git clone --depth=1 https://github.com/cpcsdk/vim-z80-democoding.git

ADD data/bashrc /home/arnold/.bashrc
ADD data/vimrc /home/arnold/.vimrc
ADD data/ctags /home/arnold/.ctags

# Add the script that properly manage the usage rights
COPY data/entrypoint.sh /usr/local/bin/entrypoint.sh

# Specify environement variales of interest
ENV CPCT_PATH /usr/local/cpctelera/cpctelera-1.4.2/cpctelera
ENV AKS_TRAKER2_PATH "/opt/Arkos Tracker 2"
ENV PATH "/opt/Arkos Tracker 2:/opt/Arkos Tracker 2/tools:/opt/arnoldemu/:$CPCT_PATH/tools/scripts/:$PATH"

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
