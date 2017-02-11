#!/bin/bash


# Bootstrap script needed to launch the environement
#

# Specific variables for the current project

DOCKER_IMAGE=cpcsdk/crossdev
DSK_TEST=experts_bugfixed.dsk


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
	;;

windows)
	LOCAL_WORKING_DIRECTORY=/$(pwd)
	DOCKER_WORKING_DIRECTORY=//home/arnold/project
	DOCKER_X11_FORWARDING=""
	;;
esac

DOCKER=docker
DOCKER_HOSTNAME=$(basename $(pwd))


function buildImage
{
    if test "$DOCKER_IMAGE" != "cpcsdk/crossdev"
    then
    	$DOCKER build -t $DOCKER_IMAGE .
    else
	echo "You need to create another image than cpcsdk/crossdev !" 2>&1
	exit 1
    fi
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
    if test "$DOCKER_IMAGE" != "cpcsdk/crossdev"
    then
 	   $DOCKER rmi $DOCKER_IMAGE
    else
	    echo "You cannot remove the cpcsdk/crossdev image !" 2>&1
	    exit 1
    fi
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
		launch
		;;
    "")
        launchImage
		;;
    *)
		launchImage $*
esac




