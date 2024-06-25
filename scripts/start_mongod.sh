#!/bin/bash
mode=$1
t=$2
basepath="/home/wjxt/gxr/testMongoDB"
config_dir="$basepath/config"


config_array=()
for ((port=1; port<=t; port++)); do
    config_array+=("${config_dir}/mongod${port}.conf")
done

if [[ "$mode" == true ]];then
	sudo mongod --config "$config_dir/mongod1.conf" --fork 
else
	i=0
    for conf_file in "${config_array[@]}"; do
        if [ -f "$conf_file" ] && [ $i -lt $t ]; then
            # echo "Starting MongoDB with configuration file: $conf_file" 
            sudo mongod --config "$conf_file"  --fork 
			i=$((i+1))
		else
			break
        fi
    done
fi


