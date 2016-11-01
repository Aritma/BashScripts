#!/bin/bash

if [ $1 ]
then

    inputDir="/home/ubuntu/workspace/etc/engetoStart"

    if [ $2 ]
    then
        if [ -d "/home/ubuntu/workspace/$2" ]
        then
            destDir="/home/ubuntu/workspace/$2"
        else
            echo "Error: User $2 is not valid!"
            exit
        fi
    else
        destDir="/home/ubuntu/workspace/Student*"
    fi
    
    if [ $1 == "restore" ]
    then
        echo -e "FUNCTION: Restore relevant content\n"
        for a in $destDir
        do
            cp -rv $inputDir $a
        done
    elif [ $1 == "repair" ]
    then
        echo -e "FUNCTION: Repair relevant content"
        for a in $destDir
        do
            cp -rnv $inputDir $a
        done
    elif [ $1 == "clear" ]
    then
        echo -e "FUNCTION: Clear relevant content"
        for a in $destDir
        do
            rm -rv $a/$(basename $inputDir)
        done
    elif [ $1 == "--help" ]
    then
        echo -e "Usage: $(basename $0) [function] [studentNum]\n
i.e. $(basename $0) restore 01  -> overwrite all relevant content of user Student01\n
---------\n
Functions:\n
restore - owerwrite all relevant content of user\n
repair - add all relevant missing files (do not repair content of files) in users folder\n
clear - remove all relevant files in users folder\n
---------\n
studentNum:\n
Name of user to apply function (Student01, Student02)\n
If not defined, function is applied for all Student* users.
"
    else
        echo "Error: Wrong parameter"
    fi
else
    echo "Set action parameter:"
    echo "restore  - restore all Student folders"
    echo "repair   - repair missing files"
    echo "clear    - clear all folders"
fi
