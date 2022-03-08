#!/bin/bash
# History: 2019-10-16 Wang 检查进程报警
# Description: This script is for checking process of nodes such as vppp,sock,etc.
# set -x
#
# 传参判断
function ProcessRe() {
    [[ $1 == "WARNING" ]] && echo ".$2.WARNING" && return 0
    [[ $1 -lt 1 ]] && echo ".$2"
}

# 通用检查方法
function chkcmd() {
    local proc_name_main=$1
    local proc_name_minor=$2
    local result_command
    [[ -n "$2" ]] || proc_name_minor=$1
    result_command=$(pgrep -alf "${proc_name_main}\b" | awk -F " " '{$1="";print}' | grep -v grep | grep -c "${proc_name_minor}" 2>&1)
    if [[ -n "$(echo "${result_command}" | sed -n "/^[0-9]\+$/p")" ]]; then
        echo "${result_command}"
    else
        echo "WARNING"
    fi
}

#进程判断
function ProcessTwo() {
    local vpl2tp=1
    local re_l2tp
    dpkg -l ysnet-l2tpns >/dev/null 2>&1 && {
        vpl2tp=$(chkcmd vppp_l2tp)
    }
    re_l2tp=$(
        ProcessRe "${vpl2tp}" vppp_l2tp
    )
    echo "${re_l2tp}" | tr -d '\n'
}

function ProcessFour() {
    local socksp=1
    local sockst=1
    local socksu=1
    local socksv=1
    local re_sock
    dpkg -l ysnet-socks5 >/dev/null 2>&1 && {
        socksp=$(chkcmd socks5_plur)
        sockst=$(chkcmd socks5)
        socksu=$(chkcmd socks5udp)
        socksv=$(chkcmd vppp_sock5)
    }
    re_sock=$(
        ProcessRe "${sockst}" socks5
        ProcessRe "${socksu}" socks5udp
        ProcessRe "${socksv}" vppp_sock5
        ProcessRe "${socksp}" sock5_plur
    )
    echo "${re_sock}" | tr -d '\n'
}

function ProcessFive() {
    local ikev2=1
    local re_ikev
    dpkg -l ysnet-ikev >/dev/null 2>&1 && {
        ikev2=$(chkcmd vppp_ikev2)
    }
    re_ikev=$(
        ProcessRe "${ikev2}" ikev2
    )
    echo "${re_ikev}" | tr -d '\n'
}

function ProcessEcho() {
    local udpecho=1
    local re_echo
    dpkg -l ysnet-udpecho >/dev/null 2>&1 && {
        udpecho=$(chkcmd echo_udp)
    }
    re_echo=$(ProcessRe "${udpecho}" echo_udp)
    echo "${re_echo}" | tr -d '\n'
}

function ProcessPing() {
    local p_pingok=1
    local re_pingok
    dpkg -l ysnet-pingok >/dev/null 2>&1 && {
        p_pingok=$(chkcmd pingok)
    }
    re_pingok=$(ProcessRe "${p_pingok}" pingok)
    echo "${re_pingok}" | tr -d '\n'
}

function ProcessProxy() {
    local re_proxy
    local num_proxy=1
    dpkg -l ysnet-proxy >/dev/null 2>&1 && {
        num_proxy=$(chkcmd httpproxy)
    }
    re_proxy=$(ProcessRe "${num_proxy}" httpproxy)
    echo "${re_proxy}"
}
