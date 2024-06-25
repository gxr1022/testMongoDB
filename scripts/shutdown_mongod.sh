#!/bin/bash
mode=$1
basepath="/home/gxr/mongodb-run/testMongoDB"
config_dir="$basepath/config"
t=48
config_array=()
for ((port=1; port<=t; port++)); do
    config_array+=("${config_dir}/mongod${port}.conf")
done

if [[ "$mode" == true ]];then
	sudo mongod --config "$config_dir/mongod1.conf" --shutdown
else
	# i=0
    for conf_file in "${config_array[@]}"; do
        # if [ -f "$conf_file" ] && [ $i -lt $t ]; then
            # echo "Starting MongoDB with configuration file: $conf_file" 
        sudo mongod --config "$conf_file" --shutdown
			# i=$((i+1))
		# else
		# 	break
        # fi
    done
fi

sudo $basepath/scripts/clear_ramdisk.sh