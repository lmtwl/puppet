#!/bin/bash
# History: 2019-7-9
# --------2020-09-17 调整结构
# Description: This shell is for checking memrory and swap of the machine
# set -x
#
function GetMemory() {
    local mem_occupy
    local swap_total
    local swap_occupy
    mem_occupy=$(free | awk '/Mem/ {print int($3/$2*100)}')
    swap_total=$(free | grep Swap | awk '{print $2}')
    if ((swap_total == 0)); then
        ((mem_occupy > 90)) && echo "mem"
    else
        swap_occupy=$(free | awk '/Swap/ {print int($3/$2*100)}')
        ((swap_occupy > 60)) && echo "swap"
    fi
}
