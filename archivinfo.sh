#!/bin/bash

if [ $1 ]
then
    file=$1
else echo -n "Enter file: "
     read file
fi
path="/tmp/archivinfo_dir"
mkdir $path
unzip $file -d $path > /dev/null

echo "All files in dirs and subdirs"
for i in $(find $path -type f)
do
    if [ -d $i ]
    then echo -n ""
    else
        echo "filename: $(basename $i)"
        echo "size: $(ls -lh $i | cut -f5 -d " ")"
        echo "last-mod: $(ls -lh $i | tr -s " " | cut -f6-8 -d " ")"
        echo "-----------"
    fi
done

rm -r $path

