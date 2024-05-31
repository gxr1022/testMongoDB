#!/bin/bash
basepath="/home/gxr/mongodb-run"
for ((i=1; i<=24; i++)); do
    id+=($i)ls 
done

for i in ${id[*]}; do
    sudo rm -rf $basepath/ramDisk/mongodb${i}
    sudo mkdir -p $basepath/ramDisk/mongodb${i}
done 

