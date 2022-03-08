#!/bin/bash
# Description: This shell is for checking the number of connections
# History: 2020-09-25
# set -x
#

function GetTcpConnect() {
    local tcpconnect_num
    tcpconnect_num=$(ss -to state established | wc -l)
    echo "${tcpconnect_num}"
}
function GetProxyConnect() {
    local proxyconnect_num
    proxyconnect_num=$(ss -p | grep -c tcp-proxy)
    echo "${proxyconnect_num}"
}
function GetUdpConnect() {
    local udpconnect_num
    udpconnect_num=$(ss -nsl | sed -n '7p' | awk '{print $2}')
    echo "${udpconnect_num}"
}
