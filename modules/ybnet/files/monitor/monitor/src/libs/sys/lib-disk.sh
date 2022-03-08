#!/bin/bash
# History: 2019-6-26
# -------: 重构磁盘报警清理逻辑
# Description: Checking the occupy of the disk
# set -x
#
function GetDevRate() {
    local dev_name=$1
    local dev_rate
    dev_rate=$(df -hP | grep "${dev_name}" | awk '{print $5}' | awk -F % '{print $1}')
    echo "${dev_rate}"
}

function GetDisk() {
    local dev_list
    local disk_used
    dev_list=$(df -hP | grep "^/dev/*" | grep -v loop | cut -d' ' -f1 | sort)
    for i in ${dev_list[*]}; do
        disk_used=$(GetDevRate "$i")
        if ((disk_used >= 80)); then
            echo "disk"
        fi
    done
}
