#!/bin/bash
# By : Wang
# History : 2019-8-27
# Description : proxy系列重启；
# ------------: 适配14.04、16.04、18.04、20.04,部分机器service start无法启动
# set -x
#

function restart_service() {
    local result_service="failed"
    local service_name=$1
    local process_name=${2:-"tcp-proxy"}
    local present_pid
    local check_pid
    check_pid=$(pgrep "${process_name}")
    /etc/init.d/"${service_name}" stop
    sleep 1
    /etc/init.d/"${service_name}" start
    sleep 1
    present_pid=$(pgrep "${process_name}")
    [[ -n ${present_pid} ]] && [[ ${present_pid} != "${check_pid}" ]] && result_service="successfully"
    echo "$(date +%F_%T) ${service_name} restart ${result_service}:${check_pid}.${present_pid}" >>/var/log/restart_service.log
}
