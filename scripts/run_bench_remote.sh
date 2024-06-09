#!/bin/bash
# set -x
mode=$1
RUN_PATH="/home/wjxt/gxr/testMongoDB"
config_dir="$RUN_PATH/config"

current=`date "+%Y-%m-%d-%H-%M-%S"`
time_interval=60

ip_address="172.20.208.111"

sudo "$RUN_PATH/scripts/clear_ramdisk.sh"

# threads=(1)
# for ((i = 4; i <= 48; i += 4)); do
#     threads+=($i)
# done

threads=(40)

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
thread_bind=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63)
for td in ${thread_bind[*]};do
    thread_binding_seq+=",$td"
done

uri_set="mongodb://$ip_address:27017"
for ((port=27018; port<=27064; port++)); do
    uri_set+=",mongodb://$ip_address:$port"
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
--URI="mongodb://172.20.208.111:27017" \
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
