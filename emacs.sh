#!/bin/bash

usage="$(basename "$0") [-h] [-v, --volume directory] [-ip, --ip ip address] -- 
script to start emacs:\n
    -h  show this help text\n
    -v, --volume A local host dicrectory that will be bound to the 
/home/python/work direcotry. The default is the 'PWD/..'.\n
    -ip, --ip IP address of X11 host. The default is grabbed from 'ip.appspot.com'\n"

# Set some defaults

PWD=`pwd`

VOLUME=${PWD}/..

IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
xhost + $IP

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -v|--volume)
            VOLUME="$2"
            shift # past argument
            ;;
        -ip|--ip)
            IP="$2"
            shift # past argument
            ;;
        -h|--help)
            echo $usage
            exit
            ;;
    esac
    shift # past argument or value
done

# Maven / Clojure deps
MAVEN=${HOME}/.m2
mkdir -p ${MAVEN}

docker run --name emacs \
       -v ${MAVEN}:/home/python/.m2 \
       -v ${HOME}/.ssh:/home/python/.ssh \
       -v ${VOLUME}:/home/python/work \
       -v ~/.gitconfig:/home/python/.gitconfig \
       -v /tmp/.X11-unix:/tmp/.X11-unix \
       -e DISPLAY=${IP}:0 --rm -it julienchastang/emacs
