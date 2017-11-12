#!/bin/bash


# Start Arkos Tracker 2. The current folder is used as sound folder

# TODO Add options to select of folder or file

echo "Workdirectory is /sound"

docker run -e DISPLAY=$DISPLAY \
	-v /tmp/.X11-unix:/tmp/.X11-unix   \
	-v /dev/snd:/dev/snd \
	-v /dev/shm:/dev/shm \
	-v /etc/machine-id:/etc/machine-id \
	-v /run/user/$(id -u)/pulse:/run/user/$(id -u)/pulse \
	-v /var/lib/dbus:/var/lib/dbus \
	-v ~/.pulse:/home/arnold/.pulse \
	-v $(pwd):/sound\
	--privileged \
	--rm=true \
	-i -t cpcsdk/crossdev \
	Arkos\ Tracker\ 2




