#!/bin/sh


# Bootstrap script needed to launch the environement


DOCKER_IMAGE=cpcsdk/crossdev

LOCAL_WORKING_DIRECTORY=$(pwd)
DOCKER_WORKING_DIRECTORY=/home/arnold/project

DOCKER=$(which docker)
DOCKER_HOSTNAME=$(basename $(pwd))

$DOCKER run \
	-h $DOCKER_HOSTNAME \
	-v $LOCAL_WORKING_DIRECTORY:$DOCKER_WORKING_DIRECTORY \
	-w $DOCKER_WORKING_DIRECTORY \
	--rm=true \
	-i \
       	-e DISPLAY=$DISPLAY \
       	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-t $DOCKER_IMAGE
