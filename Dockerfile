# The aim of this Dockerfile is to produce a
# docker machine able to manage Amstrad CPC projects.
# It mainly comes from a Makefile I maintened for such things
#
# It should be reconstructed from time to time as some tools
# evolve without changing their URL (vasm for example)


# 2018-01-21 Update forced

FROM ubuntu:18.04
MAINTAINER Romain Giot <giot.romain@gmail.com>

ENV TERM xterm-256color
RUN echo 'Etc/UTC' > /etc/timezone
RUN ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime
RUN rm -rf /var/lib/apt/lists/* && apt-get clean && apt-get update && apt-get install -qy make tzdata


# Prepare construction
RUN mkdir /cpcsdk
WORKDIR /cpcsdk
ADD data/dependencies.mk /cpcsdk/dependencies.mk
RUN make -f /cpcsdk/dependencies.mk setup

# build all the tools downloaded from the net
ADD data/Makefile /cpcsdk/Makefile
RUN make install_all

# Compile rasm that is embeded in the data
ADD data/rasm_*.zip /tmp
WORKDIR /tmp
RUN unzip rasm_*.zip && gcc *.c -O2 -lm -lrt -march=native -o /usr/local/bin/rasm -lm && rm -rf * && strip /usr/local/bin/rasm
WORKDIR /cpcsdk

#Install rust
RUN mkdir -p /opt/rust
ENV RUSTUP_HOME /opt/rust
ENV CARGO_HOME /opt/rust
RUN cd /opt/rust && curl https://sh.rustup.rs -sSf  | sh -s -- -y --default-toolchain=nightly
ENV PATH "/opt/rust/bin:$PATH"
RUN rustup completions bash > /etc/bash_completion.d/rustup.bash-completion
RUN rustup update
RUN apt-get update && apt-get install -qy libssl-dev
RUN cargo install --git=https://github.com/cpcsdk/rust.cpclib.git --all-features # update to  0.2.12-beta



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
ENV PATH "/opt/rust/bin/:/opt/Arkos Tracker 2:/opt/Arkos Tracker 2/tools:/opt/arnoldemu/:$CPCT_PATH/tools/scripts/:$PATH"

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
