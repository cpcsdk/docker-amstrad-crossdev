#!/bin/bash

hostdir=$(pwd)
dockerdir=/aftdir

ls *.sna *.dsk
docker run --rm=true \
	--env="LD_LIBRARY_PATH=/usr/local/lib" \
	-v $hostdir:$dockerdir \
	--device /dev/ttyUSB0 \
	--workdir "$dockerdir" \
	-t cpcsdk/crossdev \
	/usr/local/bin/aft-minibooster $*


