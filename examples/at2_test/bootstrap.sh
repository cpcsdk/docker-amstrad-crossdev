#!/bin/bash


# Bootstrap script needed to launch the environement
#

DOCKER_IMAGE=benediction/at2_test
DSK_TEST=./at2_test.dsk




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

DOCKER_BASEIMAGE=$(grep FROM Dockerfile | sed -e 's/^FROM\s*//')

DOCKER_IMAGE_DATE=$(docker images --format="{{.CreatedAt}}" $DOCKER_IMAGE)

if [[ $DOCKER_BASEIMAGE == *:* ]]
then
DOCKER_BASEIMAGE_DATE=$(docker images --format="{{.CreatedAt}}" $DOCKER_BASEIMAGE)
else
DOCKER_BASEIMAGE_DATE=$(docker images --format="{{.CreatedAt}}" $DOCKER_BASEIMAGE:latest)
fi

echo $DOCKER_BASEIMAGE_DATE

# XXX Attention here it is not portable at all
# XXX Need to find a way which works everywhere
DOCKER_BASEIMAGE_DATE=$( echo "$DOCKER_BASEIMAGE_DATE" | sed -e 's/..... CES\?T//')
DOCKER_IMAGE_DATE=$( echo "$DOCKER_IMAGE_DATE" | sed -e 's/..... CES\?T//')

DOCKER_BASEIMAGE_DATE=$(date -d "$DOCKER_BASEIMAGE_DATE"  '+%s')
DOCKER_IMAGE_DATE=$(date -d "$DOCKER_IMAGE_DATE"  '+%s')



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




