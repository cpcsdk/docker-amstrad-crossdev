#!/bin/bash


# Start grafx2. The current folder is used as pictures folder
# TODO Add options to select of folder or file

echo "Workdirectory is /pictures"

docker run -e DISPLAY=$DISPLAY \
	-v /tmp/.X11-unix:/tmp/.X11-unix   \
	-v /dev/snd:/dev/snd \
	-v /dev/shm:/dev/shm \
	-v /etc/machine-id:/etc/machine-id \
	-v /run/user/$(id -u)/pulse:/run/user/$(id -u)/pulse \
	-v /var/lib/dbus:/var/lib/dbus \
	-v ~/.pulse:/home/arnold/.pulse \
	-v $(pwd):/pictures \
	--privileged \
	--rm=true \
	-i -t cpcsdk/crossdev \
	bash -c 'cd /pictures && grafx2'




