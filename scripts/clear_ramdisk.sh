#!/bin/bash
basepath="/home/gxr/mongodb-run"
id=()
for ((i=1; i<=48; i++)); do
    id+=($i)
done

for i in ${id[*]}; do
    # echo ${i}
    sudo rm -rf ${basepath}/ramDisk/mongodb${i}
    sudo mkdir -p ${basepath}/ramDisk/mongodb${i}
done 

