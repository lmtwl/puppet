#!/bin/bash
# History: 2020-09-18
# Description: 取mem占用前三进程
# set -x
#
function GetMemoryProcess(){
    local process
    process=$(top -bn 1 |sed '1,6d' | sort -k10nr | head -3 | awk '{print $12}'| awk '{printf "%s,",$0}')
    echo "${process}"
}