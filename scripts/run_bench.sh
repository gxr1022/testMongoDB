#!/bin/bash

sudo /mnt/nvme0/home/gxr/mongdb-run/test_mongodb_simple/scripts/clear_ramdisk.sh

config_dir="/mnt/nvme0/home/gxr/mongdb-run/test_mongodb_simple/config"
current=`date "+%Y-%m-%d-%H-%M-%S"`
RUN_PATH="/mnt/nvme0/home/gxr/mongdb-run/test_mongodb_simple"

time_interval=300

set -x


first_mode=(true false)
# first_mode=(false)

# threads=(
# 	1
# 	2
# 	4
# 	6
# 	8
# 	10
# 	12
# 	14
# 	16
# 	18
# 	20
# 	22
# 	24
# )

threads=(1)
for ((i = 8; i <= 128; i += 8)); do
    threads+=($i)
done

# threads=(8)

hs=(
run_clients
)

kv_sizes=(
	# "16 16"
	# "16 64"
	"8 100"
	# "16 4096"
)

LOG_PATH=${RUN_PATH}/log/${current}
BINARY_PATH=${RUN_PATH}/build/

mkdir -p ${LOG_PATH}

# echo "init ok "

pushd ${RUN_PATH}

cmake -B ${BINARY_PATH} -DCMAKE_BUILD_TYPE=Release ${RUN_PATH}  2>&1 | tee ${RUN_PATH}/configure.log
if [[ "$?" != 0  ]];then
	exit
fi
cmake --build ${BINARY_PATH}  --verbose  2>&1 | tee ${RUN_PATH}/build.log

if [[ "${PIPESTATUS[0]}" != 0  ]];then
	cat ${RUN_PATH}/build.log | grep --color "error"
	echo ${RUN_PATH}/build.log
	exit
fi

for t in ${threads[*]};do

config_array=()
for ((port=1; port<=t; port++)); do
    config_array+=("${config_dir}/mongod${port}.conf")
done

thread_binding_seq="0"
thread_bind=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255)
for td in ${thread_bind[*]};do
    thread_binding_seq+=",$td"
done

echo $thread_binding_seq

# thread_binding_seq="0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191"

# thread_binding_seq="0,1,2,3,4,5,6,7,8,9,10,11,24,25,26,27,28,29,30,31,32,33,34,35"

uri_set="mongodb://localhost:27017"
for ((port=27018; port<=27272; port++)); do
    uri_set+=",mongodb://localhost:$port"
done
# echo "$uri_set"


for kv_size in "${kv_sizes[@]}";do

kv_size_array=( ${kv_size[*]} )
key_size=${kv_size_array[0]}
value_size=${kv_size_array[1]}

for h in ${hs[*]};do


for mode in "${first_mode[@]}"; do

sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"


if [[ "$mode" == true ]];then
	sudo mongod --config "$config_dir/mongod1.conf"  --fork 
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


h_name=$(basename ${h})


cmd="numactl --membind=0 \
${BINARY_PATH}/${h} \
--num_threads=${t} \
--core_binding=${thread_binding_seq} \
--str_key_size=${key_size} \
--str_value_size=${value_size} \
--URI_set=${uri_set} \
--time_interval=${time_interval} \
--first_mode=${mode}
"


this_log_path=${LOG_PATH}/${h_name}.${t}.thread.${mode}.${key_size}.${value_size}.log

echo ${cmd} 2>&1 |  tee ${this_log_path}

# sleep 5


# monitor need sudo

# gdbserver :1234 \
# sudo \
timeout -v 3600 \
stdbuf -o0 \
${cmd} 2>&1 |  tee -a ${this_log_path}
echo log file in : ${this_log_path}

# sleep 10



if [[ "$mode" == true ]];then
	# sudo systemctl stop mongod
    sudo mongod --config "$config_dir/mongod1.conf" --shutdown
else
	i=0
    for conf_file in "${config_array[@]}"; do
		if [ -f "$conf_file" ] && [ $i -lt $t ]; then
            sudo mongod --config "$conf_file" --shutdown
        	# echo "Stopped MongoDB instance using configuration: $conf_file"
			i=$((i+1))
		else
			break
        fi
    done
fi

sudo /mnt/nvme0/home/gxr/mongdb-run/test_mongodb_simple/scripts/clear_ramdisk.sh

done
done
done
done


popd
