#!/bin/bash
# By : Wang
# History : 2019-8-26
# Description : 20C出口机器重启nproxy逻辑；
# set -x 
#

function send_alarm_before
{
    local check_ip="103.99.78."
    local local_ip
    local present_domian
    local present_code
    local check_domian="steamcommunity.com"
    present_domian=$(echo "$1" | awk -F " " '{print $1}')
    present_code=$(echo "$1" | awk -F " " '{print $3}')
    local_ip=$(ifconfig eth0|grep "inet addr"|awk '{print $2}'|awk -F: '{print $2}')
    if [[ "${present_domian}" == "${check_domian}" && "${local_ip}" == *${check_ip}* && "${present_code}" != "000" ]]; then
        source "${LIBS}"/lib-service-restart.sh
        restart_service xunyou-nproxy
    fi
}