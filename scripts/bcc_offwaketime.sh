#!/bin/bash
mode=$1
t=$2
basepath="/home/gxr/mongodb-run/testMongoDB"
config_dir="$basepath/config"
cur_date=`date "+%Y-%m-%d-%H-%M-%S"`
# echo $cur_date
log_dir="$basepath/perf_log"
perf_log_path="$log_dir/$cur_date.offwake"
mkdir -p $perf_log_path

perf_log_prefix="first_mode.offwake.$cur_date"
perf_record_file_name="$perf_log_prefix.perfdata"

perf_output_record_path="$perf_log_path/$perf_record_file_name"

bench_cmd="sudo /usr/share/bcc/tools/offwaketime -f -p `pgrep -nx mongod` 90 > $perf_output_record_path"

echo $bench_cmd
eval $bench_cmd
sudo chmod 755 $perf_output_record_path 






