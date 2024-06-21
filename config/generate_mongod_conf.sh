#!/bin/bash

conf_dir="/home/wjxt/gxr/testMongoDB/config"

num_files=64

start_port=27017

for ((i=1; i<=$num_files; i++)); do

    conf_file="$conf_dir/mongod${i}.conf"
    port=$((start_port + $i - 1))
    cat <<EOF > $conf_file
systemLog:
  destination: file
  path: "/var/log/mongodb/mongod${i}.log"
  logAppend: true
storage:
  dbPath: "/home/wjxt/gxr/testMongoDB/ramDisk/mongodb${i}"
net:
  port: $port
  bindIp: 172.20.208.111
processManagement:
  timeZoneInfo: /usr/share/zoneinfo
EOF

    echo "Generated $conf_file,端口号为 $port"
done
