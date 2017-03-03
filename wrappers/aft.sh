#!/bin/bash


# Usage:
#    AFTDEVICE=/dev/ttyUSB1 aft.sh -p /dev/ttyUSB1
#    aft.sh

hostdir=$(pwd)
dockerdir=/aftdir


AFTDEVICE=${AFTDEVICE:-/dev/ttyUSB0}

ls *.sna *.dsk
docker run --rm=true \
	--env="LD_LIBRARY_PATH=/usr/local/lib" \
	-v $hostdir:$dockerdir \
	--device $AFTDEVICE \
	--workdir "$dockerdir" \
	-t cpcsdk/crossdev \
	/usr/local/bin/aft-minibooster $*


