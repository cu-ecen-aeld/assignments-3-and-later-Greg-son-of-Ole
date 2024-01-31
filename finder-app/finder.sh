#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Error: 2 arguments are required"
    echo " The first argument is a path to a directory on the filesystem"
    echo " The second argument is a text string which will be searched within these files"
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "Error: specified directory $1 does not exist"
    exit 1
fi

#$TOTAL = grep -R "text" $1 | wc -l
#echo "The number of files are" $TOTAL

#minnesota

NUMFILES=$(find $1 -type f | wc -l)
NUMLINES=$(grep -R -o $2 $1 | wc -l)
echo "The number of files are" $NUMFILES "and the number of matching lines are" $NUMLINES

