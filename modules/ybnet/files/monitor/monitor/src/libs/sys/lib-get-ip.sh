#!/bin/bash
# History: 2019-5-15
# -------- 2020-09-16 update：优化取真实IP逻辑,适配vpn节点、模式四节点和ROS节点
# Description: 报警上报接口
# set -x
#
FILE="/etc/nodeinfo.ini"

function GetVppp() {
    local file=$1
    local vppp_var
    vppp_var=$(grep id "${file}" | awk -F "[=_]" '{print $2}' | tr -d "[:alpha:]")
    echo "${vppp_var}"
}

function GetId() {
    local file_socks5
    local real_ip=""
    file_socks5="/opt/ysnet/socks5/etc/vppp.conf"

    if [[ -f "${file_socks5}" ]]; then
        real_ip=$(GetVppp ${file_socks5})
    else
        real_ip=$(grep host_name "${FILE}" | awk -F ":" '{print $2}' | tr -cd "[0-9].")
    fi
    echo "${real_ip}"
}

function GetName() {
    local name
    [[ -f "${FILE}" ]] && {
        name=$(grep node_name "${FILE}" | awk -F ":" '{print $2}')
        if [[ -n "${name}" ]]; then
            echo "${name}"
        else
            return 0
        fi
    }
}
