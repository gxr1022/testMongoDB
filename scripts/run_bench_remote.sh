#!/bin/bash
# t=$1
sudo /mnt/nvme0/home/gxr/mongdb-run/test_mongodb_simple/scripts/clear_ramdisk.sh

config_dir="/mnt/nvme0/home/gxr/mongdb-run/test_mongodb_simple/config"
current=`date "+%Y-%m-%d-%H-%M-%S"`
RUN_PATH="/mnt/nvme0/home/gxr/mongdb-run/test_mongodb_simple"

time_interval=10
mode=true
# set -x


# threads=(104)
# for ((i = 112; i <= 128; i += 8)); do
#     threads+=($i)
# done

threads=(96)

hs=(
run_clients
)

kv_sizes=(
	# "16 16"
	# "16 64"
	"8 100"
	# "16 4096"
)

LOG_PATH=${RUN_PATH}/log_remote/${current}
BINARY_PATH=${RUN_PATH}/build/

mkdir -p ${LOG_PATH}

echo "init ok "

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

thread_binding_seq="0"
thread_bind=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127)
for td in ${thread_bind[*]};do
    thread_binding_seq+=",$td"
done

uri_set="mongodb://172.16.33.30:27017"
for ((port=27018; port<=27144; port++)); do
    uri_set+=",mongodb://172.16.33.30:$port"
done
# echo "$uri_set"

for t in ${threads[*]};do
for kv_size in "${kv_sizes[@]}";do

kv_size_array=( ${kv_size[*]} )
key_size=${kv_size_array[0]}
value_size=${kv_size_array[1]}

for h in ${hs[*]};do

sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
h_name=$(basename ${h})

cmd="numactl --membind=0 \
${BINARY_PATH}/${h} \
--num_threads=${t} \
--core_binding=${thread_binding_seq} \
--str_key_size=${key_size} \
--str_value_size=${value_size} \
--URI_set=${uri_set} \
--URI="mongodb://172.16.33.30:27017" \
--time_interval=${time_interval} \
--first_mode=${mode}
"
this_log_path=${LOG_PATH}/${h_name}.${t}.thread.${mode}.${key_size}.${value_size}.log
echo ${cmd} 2>&1 |  tee ${this_log_path}

timeout -v 3600 \
stdbuf -o0 \
${cmd} 2>&1 |  tee -a ${this_log_path}
echo log file in : ${this_log_path}

done
done
done

popd
