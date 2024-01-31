#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Error: 2 arguments are required"
    echo " The first argument is a file name, including the path, which will be created"
    echo " The second argument is a text string which will be written to that file"
    exit 1
fi

DIRECTORY=$(dirname $1)
FILE=$(basename $1)

if [ ! -d $DIRECTORY ]; then
    mkdir $DIRECTORY
fi

if [ ! -d $DIRECTORY ]; then
    echo "Error creating path"
    exit 1
fi

touch $1

if [ ! -f $1 ]; then
    echo "Error creating file"
    exit 1
fi

echo $2 > $1
