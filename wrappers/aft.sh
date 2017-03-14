#!/bin/bash


# Usage:
#    AFTDEVICE=/dev/ttyUSB1 aft.sh 

hostdir=$(pwd)
dockerdir=/aftdir

if test -z "$AFTDEVICE"
then
	AFTDEVICE=/dev/ttyUSB0
fi


echo "Use port $AFTDEVICE"
ls *.sna *.dsk
docker run --rm=true \
	--env="LD_LIBRARY_PATH=/usr/local/lib" \
	-v $hostdir:$dockerdir \
	--device $AFTDEVICE \
	--workdir "$dockerdir" \
	-t cpcsdk/crossdev \
	/usr/local/bin/aft-minibooster -p $AFTDEVICE


