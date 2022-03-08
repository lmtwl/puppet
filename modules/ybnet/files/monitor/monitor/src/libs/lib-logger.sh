#!/bin/bash
# author: Fufu, 2019-03-03
# 日志记录, 文件日志
# usage: logger "日志内容" "日志文件(可选)"
# set -x
#
function logger() {
    local text=${1:-""}
    local file=${2:-"/var/log/${M_NAME}.log"}
    [[ -n "${text}" ]] && echo "$(date +%F_%T) ${text}" >>"${file}"
}
