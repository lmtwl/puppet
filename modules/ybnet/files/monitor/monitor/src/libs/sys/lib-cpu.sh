#!/bin/bash
# History: 2019-3-12
# Description: This script is mainly for checking whether cpus occupies
# set -x
#
function GetCpu(){
    local cpu
    local ncpu
    local cpuRe
    cpu=$(grep 'cpu[0-9]' /proc/stat |awk '{printf "%s %.f %.f\n",$1,$5,$2+$3+$4+$5+$6+$7+$8}')
    sleep 1
    ncpu=$(grep 'cpu[0-9]' /proc/stat |awk '{printf "%s %.f %.f\n",$1,$5,$2+$3+$4+$5+$6+$7+$8}')
    cpuRe=($(echo -e "$cpu\n$ncpu" |awk '{a[$1]=a[$1]" "$2" "$3}END{for (i in a) print i, a[i]}' |awk '{printf "%.f\n",100-($4-$2)*100/($5-$3)}'|awk '$1>80{print $1}'))
    if [[ ${#cpuRe[@]} -gt 0 ]];then
        echo "cpu"
    fi
}
