#!/bin/bash

#
# If we receive the dir to check on the commandline as an argument, use it. If not, assume we're working in the current directory.
#

if [ -n "$1" ] ; then
        WORKING_DIR="`readlink -f $1`"
    else
        WORKING_DIR="$PWD"
fi

#
# Detect and act if we're checking a Dockerfile
#

if [ -s $WORKING_DIR/Dockerfile ] ; then

    echo ""
    echo "#########################################"
    echo "#                                       #"
    echo "#        Checking Dockerfile...         #"
    echo "#                                       #"
    echo "#########################################"
    echo ""
    sleep 1
    
    #
    # Find the installed container runtime, prefer Docker if we find both
    #

    if [ `which podman` ] ; then
        echo "Found podman..."
        CONTAINER_RUNTIME=`which podman`
    fi

    if [ `which docker` ] ; then
        echo "Found docker..."
        CONTAINER_RUNTIME=`which docker`
    fi

    echo "Using $CONTAINER_RUNTIME..."

    # Run standard checks on the Dockerfile, excluding these checks:
    # -DL4000: warns that 'MAINTAINER tag is deprecated'
    # -DL3018: warns that apk is targetting 'latest' instead of specific versions
    $CONTAINER_RUNTIME run --rm -i -v $WORKING_DIR:/data ghcr.io/hadolint/hadolint /bin/hadolint --ignore DL4000 --ignore DL3018 /data/Dockerfile
    # $CONTAINER_RUNTIME run --rm -i -v $PWD:/data ghcr.io/hadolint/hadolint /bin/hadolint /data/Dockerfile
fi