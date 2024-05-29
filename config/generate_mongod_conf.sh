#!/bin/bash

conf_dir="/mnt/nvme0/home/gxr/mongdb-run/test_mongodb_simple/config"

num_files=256

start_port=27145

for ((i=129; i<=$num_files; i++)); do

    conf_file="$conf_dir/mongod${i}.conf"
    port=$((start_port + $i - 129))
    cat <<EOF > $conf_file
systemLog:
  destination: file
  path: "/var/log/mongodb/mongod${i}.log"
  logAppend: true
storage:
  dbPath: "/mnt/nvme0/home/gxr/mongdb-run/ramDisk/mongodb${i}"
net:
  port: $port
  bindIp: 127.0.0.1
processManagement:
  timeZoneInfo: /usr/share/zoneinfo
EOF

    echo "Generated $conf_file,端口号为 $port"
done
