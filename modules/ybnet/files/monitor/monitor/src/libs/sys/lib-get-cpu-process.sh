#!/bin/bash
# History: 2020-09-16
# Description: 取CPU占用前三的进程
# set -x
#
function GetCpuProcess(){
    local process 
    process=$(top -bn 1 | head -10 | tail -3 | awk '{print $12}'| awk '{printf "%s,",$0}')
    echo "${process}"
}