#!/bin/bash
for ((i=1; i<=256; i++)); do
    id+=($i)
done

for i in ${id[*]}; do
    sudo rm -rf /mnt/nvme0/home/gxr/mongdb-run/ramDisk/mongodb${i}
    sudo mkdir -p /mnt/nvme0/home/gxr/mongdb-run/ramDisk/mongodb${i}
done 

