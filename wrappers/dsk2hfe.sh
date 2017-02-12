#!/bin/bash


if ! test $# -eq 1
then
	echo "Usage:" >&2
	echo "$0 FNAME.dsk" >&2
	exit -1
fi


input="$1"
if ! test -f "$input"
then
	echo "$input does not exist" >&2
	exit -1
fi

dockerdir=/tmp
hostdir=$(realpath $(dirname "$input"))


input=$dockerdir/$(basename "$input")
output=$(dirname "$input")/$(basename "$input" .dsk).hfe

echo Convert $input to $output

docker run --rm=true \
	--env="LD_LIBRARY_PATH=/usr/local/lib" \
	-v $hostdir:$dockerdir \
	-t cpcsdk/crossdev \
	/usr/local/bin/hxcfe "-finput:$input" "-foutput:$output" -conv:HXC_HFE


