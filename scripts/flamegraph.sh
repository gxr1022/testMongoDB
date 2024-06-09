#!/bin/bash
cur_date=$1
basepath="/home/gxr/mongodb-run/testMongoDB"
log_dir="$basepath/perf_log"
perf_log_path="$log_dir/$cur_date"

# perf_log_prefix="first_mode.$cur_date"
# perf_record_file_name="$perf_log_prefix.perfdata"

# perf_output_record_path="$perf_log_path/$perf_record_file_name"

FILES=$(ls $perf_log_path | grep perfdata)
# FILES=($FILES[@])
# echo "$FILES"
perf_exec="/home/gxr/mongodb-run/tools/FlameGraph/stackcollapse-perf.pl"

flame_exec="/home/gxr/mongodb-run/tools/FlameGraph/flamegraph.pl"

output_dir="$basepath/svg_output/$cur_date"
# output_dir=`realpath $output_dir`
mkdir -p $output_dir

pushd $perf_log_path
# for file in "${FILES[@]}"; do
while read -r line ; do
    echo $line
    # echo $file
    # exit
    # mv files perf.data
    # svg_name=`echo $line | awk  -F '.' '{print $NF}'`
    svg_name="$line.svg"
    echo $svg_name
    svg_path="$output_dir/$svg_name"
    # exit
    file_name=$line
    # sudo perf script > out.perf 
    perf_cmd="sudo perf script --input=$file_name | $perf_exec | $flame_exec --colors=io --title=\"Off-CPU Flame Graph\" > $svg_path"
    echo $perf_cmd
    # exit
    eval $perf_cmd
    # ../../FlameGraph/stackcollapse-perf.pl  ./out.perf  > out.folded 
    # ../../FlameGraph/flamegraph.pl  ./out.folded  > out.svg 

    # one_bench_log_prefix="$disk_type.$bench_log_name.$num.$value_size"
    # mv out.svg one_bench_log_prefix.svg
  
done <<< "${FILES[@]}"
# done < <(ls $path | grep perfdata)
popd



# for filename in $files
# do
#    echo $filename >> filename.txt
# done

# PATH="./logs/2022-03-29-20-50-31"
# file_name="$(basename -- $PATH)"





