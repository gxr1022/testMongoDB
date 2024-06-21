#!/bin/bash
basepath="/home/wjxt/gxr/testMongoDB"
id=()
for ((i=1; i<=64; i++)); do
    id+=($i)
done

for i in ${id[*]}; do
    sudo rm -rf $basepath/ramDisk/mongodb${i}
    sudo mkdir -p $basepath/ramDisk/mongodb${i}
done 

