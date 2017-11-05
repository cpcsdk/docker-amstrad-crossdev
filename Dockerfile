# The aim of this Dockerfile is to produce a
# docker machine able to manage Amstrad CPC projects.
# It mainly comes from a Makefile I maintened for such things
#
# It should be reconstructed from time to time as some tools
# evolve without changing their URL (vasm for example)


FROM ubuntu:17.10
MAINTAINER Romain Giot <giot.romain@gmail.com>

ENV TERM xterm-256color


RUN apt-get update && apt-get install make

RUN mkdir /cpcsdk
WORKDIR /cpcsdk
ADD data/dependencies.mk /cpcsdk/dependencies.mk
RUN make -f /cpcsdk/dependencies.mk setup
ADD data/Makefile /cpcsdk/Makefile
RUN make install_all


# AFT version for the cpc booster
ADD data/minibooster/aft /usr/local/bin/aft-minibooster
RUN chmod +x /usr/local/bin/aft-minibooster


# Create the user of interest
RUN useradd \
	--home-dir /home/arnold \
	--create-home \
	--shell /bin/bash \
	arnold
RUN addgroup arnold dialout
RUN addgroup arnold audio
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


ADD data/bashrc /home/arnold/.bashrc
ADD data/vimrc /home/arnold/.vimrc
ADD data/ctags /home/arnold/.ctags

RUN git config --global merge.tool meld

# ensure the shell will properly work

# ensure X tools can be used

