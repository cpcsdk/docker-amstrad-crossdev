#!/bin/bash


# Bootstrap script needed to launch the environement
#

DOCKER_IMAGE=benediction/experts
DSK_TEST=./experts_bugfixed.dsk



# Common code for all the projects


# OS detection code
UNAME=$(uname -s)
DETECTED_OS=linux
if test "$(expr substr $(uname -s) 1 5)" == "MINGW"
then
	DETECTED_OS=windows
fi


# Sadly, there are some  differences between windows and linux
case $DETECTED_OS in
linux)
	LOCAL_WORKING_DIRECTORY=$(pwd)
	DOCKER_WORKING_DIRECTORY=/home/arnold/project
	DOCKER_X11_FORWARDING="-e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --privileged"
	DOCKER_SOUND_CONFIGURATION="-v /dev/snd:/dev/snd -v /dev/shm:/dev/shm -v /etc/machine-id:/etc/machine-id -v /run/user/$(id -u)/pulse:/run/user/$(id -u)/pulse -v /var/lib/dbus:/var/lib/dbus -v $HOME/.pulse:/home/arnold/.pulse"
	;;

windows)
	LOCAL_WORKING_DIRECTORY=/$(pwd)
	DOCKER_WORKING_DIRECTORY=//home/arnold/project
	DOCKER_X11_FORWARDING=""
	DOCKER_SOUND_CONFIGURATION=""
	;;
esac

DOCKER=docker
DOCKER_HOSTNAME=$(basename $(pwd))
DOCKER_USER_OPTION="-e LOCAL_USER_ID=$(id -u $USER)"

DOCKER_BASEIMAGE=$(grep FROM Dockerfile | sed -e 's/^FROM\s*//')
if [[ $DOCKER_BASEIMAGE == *:* ]]
then
    DOCKER_BASEIMAGE="$DOCKER_BASEIMAGE"
else
    DOCKER_BASEIMAGE="$DOCKER_BASEIMAGE:latest"
fi


# Extract the construction date of a Docker container
# Input:
# - $1 Container name
function docker_date()
{
    docker inspect "$1" | grep -i created | sed -e 's/^.*: "//' -e 's/",.*$//'
}

# Get docker container dates (docker format)
DOCKER_IMAGE_DATE=$(docker_date $DOCKER_IMAGE)
DOCKER_BASEIMAGE_DATE=$(docker_date $DOCKER_BASEIMAGE)

# Impose a specific format to ease comparison
DATE_FORMAT_EXPECTED="%s"
DOCKER_BASEIMAGE_DATE=$(date -d "$DOCKER_BASEIMAGE_DATE"  "+$DATE_FORMAT_EXPECTED")
DOCKER_IMAGE_DATE=$(date -d "$DOCKER_IMAGE_DATE"  "+$DATE_FORMAT_EXPECTED")
DOCKERFILE_DATE=$(date -r Dockerfile "+$DATE_FORMAT_EXPECTED")


function buildImage
{
    $DOCKER build -t $DOCKER_IMAGE .
}

function launchImage
{


    # create the image if it does not exists
    if test "$($DOCKER images -q $DOCKER_IMAGE 2> /dev/null)" = "" 
    then
        buildImage
    fi
	
	# Manage parameters for aft
	# XXX Implement a better and more robust way to do things ...
	case $DETECTED_OS in 
		linux) AFT_PORT=/dev/ttyUSB0 ;;
		windows) AFT_PORT=/dev/ttyS3 ;;
	esac
	
    if  test -e "$AFT_PORT"
    then
		AFT_OPTION="--device $AFT_PORT" 
    else
		echo "aft unusable ($AFT_PORT does not exists)" >&2
		AFt_OPTION=""
	fi


    ALL_OPTIONS=" -h $DOCKER_HOSTNAME
	-v $LOCAL_WORKING_DIRECTORY:$DOCKER_WORKING_DIRECTORY
	-w $DOCKER_WORKING_DIRECTORY
	$DOCKER_X11_FORWARDING
	$DOCKER_AFT_OPTION
	$DOCKER_SOUND_CONFIGURATION
	$AFT_OPTION
    $DOCKER_USER_OPTION
	--rm=true
	-i
	-t
	$DOCKER_IMAGE
    $*"


    # launch the image
    echo Use these options: "$ALL_OPTIONS"
    $DOCKER run $ALL_OPTIONS

}

function removeImage
{
    $DOCKER rmi $DOCKER_IMAGE
}


function doHelp
{
    echo "$1 [help | rebildImage | removeImage | launchImage | <cmd ...>]"
    echo -e '\thelp: display help'
    echo -e '\trebuildImage: reconstruct the Docker image'
    echo -e '\tremoveImage: delete the Docker image'
    echo -e '\tlaunchImage: launch the docker image and provides a prompt'
    echo -e '\ttest: launch an emulator on the result'
    echo -e '\t<cmd ...>: execute the command on the docker image'
    echo
    echo The operation launchImage is operated if no option is given
}


function launch
{
   xdg-open $DSK_TEST
}



function checkImageCoherence
{

if test "$DOCKER_BASEIMAGE_DATE" -gt "$DOCKER_IMAGE_DATE"
then
  echo "Parent image is newer -- I need to rebuild mine !!\n"
  buildImage
fi

if test "$DOCKERFILE_DATE" -gt "$DOCKER_IMAGE_DATE"
then
  echo "Docker file is newer the container -- I need to rebuild it !!\n"
  buildImage

fi
}



case "$1" in
    rebuildImage)
        buildImage
        ;;
    removeImage)
        removeImage
        ;;
    help)
		doHelp $0
		;;
    test)
      checkImageCoherence
      launch
		;;
    "")

      checkImageCoherence
      launchImage
		;;
    *)
      checkImageCoherence
      launchImage $*
esac




