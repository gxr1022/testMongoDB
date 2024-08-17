#!/bin/bash
# set -x

sudo -v


while true; do sudo -v; sleep 60; done &

mode=$1

SSH_PASSWORD="gxr123456"
SUDO_PASSWORD="gxr123456"

RUN_PATH="/home/wjxt/gxr/testMongoDB"
config_dir="$RUN_PATH/config"

current=`date "+%Y-%m-%d-%H-%M-%S"`

ip_address="172.20.208.111"

sudo "$RUN_PATH/scripts/clear_ramdisk.sh"

# threads=(1)
# for ((i = 4; i <= 32; i += 4)); do
#     threads+=($i)
# done

threads=(1)

num_of_ops_set=(5000 6000 7000 8000 9000 10000)
# num_of_ops_set=(10000 20000 40000 60000 80000 100000 200000 400000 600000 800000 1000000)
hs=(
run_clients
)

kv_sizes=(
	# "16 16"
	# "16 64"
	"8 100"
	# "16 4096"
)

EBPF_LOG_PATH=${RUN_PATH}/ebpf_log/${current}
LOG_PATH=${RUN_PATH}/log_remote/${current}
BINARY_PATH=${RUN_PATH}/build/

mkdir -p ${LOG_PATH}
mkdir -p ${EBPF_LOG_PATH}

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
thread_bind=(1 2 3 4 5 6 7 8 9 10 11 24 25 26 27 28 29 30 31 32 33 34 35 12 13 14 15 16 17 18 19 20 21 22 23 36 37 38 39 40 41 42 43 44 45 46 47)
for td in ${thread_bind[*]};do
    thread_binding_seq+=",$td"
done

uri_set="mongodb://$ip_address:27017"
for ((port=27018; port<=27064; port++)); do
    uri_set+=",mongodb://$ip_address:$port"
done
# echo "$uri_set"

for t in ${threads[*]}; do
	for num_of_ops in ${num_of_ops_set[*]}; do
        mongod_start_output=$(sshpass -p $SSH_PASSWORD ssh gxr@$ip_address "echo $SUDO_PASSWORD | sudo -S /home/gxr/mongodb-run/testMongoDB/scripts/start_mongod.sh true 1")
 	    mongod_pid=$(echo "$mongod_start_output" | grep -oP 'forked process: \K\d+')
        tid_output=$(ps -T -p $mongod_pid) 
        comm_array=($(echo "$tid_output" | awk 'NR>1 {print $5}'))
        
        # start eBPF profiling ……
        # ebpf_log_fname="/home/gxr/mongodb-run/ebpf_monitor/stdout_log/ebpf.${t}.thread.${mode}.${mongod_pid}.log"
        # sshpass -p $SSH_PASSWORD ssh gxr@$ip_address "echo '${SUDO_PASSWORD}' | sudo -S /home/gxr/mongodb-run/ebpf_monitor/scripts/run_lock_flow_analysis_ctrl_signal.sh ${t} ${mongod_pid}  > ${ebpf_log_fname} 2>&1 &"
        # if [ $? -eq 0 ]; then
        #     echo "Command executed successfully on Server B."
        # else
        #     echo "Error: Command execution failed on Server B."
        # fi
        # sleep 5

        # other loops
        for kv_size in "${kv_sizes[@]}"; do
            kv_size_array=( ${kv_size[*]} )
            key_size=${kv_size_array[0]}
            value_size=${kv_size_array[1]}
            
            for h in ${hs[*]}; do
                sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
                h_name=$(basename ${h})

                cmd="numactl --membind=0 \
                ${BINARY_PATH}/${h} \
                --num_threads=${t} \
                --core_binding=${thread_binding_seq} \
                --str_key_size=${key_size} \
                --str_value_size=${value_size} \
                --num_of_ops=${num_of_ops} \
                --URI_set=${uri_set} \
                --URI=mongodb://172.20.208.111:27017 \
                --pid=${mongod_pid} \
                --first_mode=${mode}"

                this_log_path=${LOG_PATH}/${h_name}.${t}.thread.${mode}.${key_size}.${value_size}.log
                echo ${cmd} 2>&1 | tee ${this_log_path}

                timeout -v 3600 stdbuf -o0 ${cmd} 2>&1 | tee -a ${this_log_path}
                echo "Log file in: ${this_log_path}"
            done
        done
        sleep 60
        # close ebpf program running on remote server
        # pid_ebpf=$(sshpass -p $SSH_PASSWORD ssh gxr@$ip_address "echo $SUDO_PASSWORD | sudo -S pgrep -f lock_flow_analysis_ctrl_signal.py | head -n 1")
        # echo ${pid_ebpf}
        # if [ -z "$pid_ebpf" ]; then
        #     echo "Process not found."
        # else
        #     echo "Process PID of eBPF: $pid_ebpf"
        # fi

        # We must ensure that print_stack is invoked before conn1 close.
        # sshpass -p $SSH_PASSWORD ssh gxr@$ip_address  "echo '${SUDO_PASSWORD}' | sudo -S kill -10 ${pid_ebpf}"
        # sleep 5 # reserve enough time to output ebpf results to file.

        # shutdown mongodb
        sshpass -p $SSH_PASSWORD ssh gxr@$ip_address "echo $SUDO_PASSWORD | sudo -S /home/gxr/mongodb-run/testMongoDB/scripts/shutdown_mongod.sh true"
        sleep 5
    done
    echo "All threads have finished."

done


popd
kill %1