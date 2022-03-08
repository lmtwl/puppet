#!/bin/bash
# History: 2019-8-27
# -------: 2020-09-25 修改逻辑
# Description: 连接数报警逻辑
# set -x
#
source "${SYS}"/lib-curl.sh
source "${SYS}"/lib-get-connect.sh

# tcp连接数报警判断
function tcp_alert() {
    [[ $(GetTcpConnect) -ge 50000 ]] && echo "tcp"
}
function proxy_alert() {
    if [[ $(GetProxyConnect) -ge 25000 ]]; then
        echo "tcp-proxy"
        dpkg -l xunyou-proxy >/dev/null 2>&1 && {
            source "${LIBS}"/lib-service-restart.sh
            restart_service xunyou-proxy
        }
        return 0
    fi
    tcp_alert
}
# udp连接数报警判断
function udp_alert() {
    [[ $(GetUdpConnect) -ge 40000 ]] && echo "udp"
}

PROXY_VAR=$(proxy_alert)
UDP_VAR=$(udp_alert)
[[ -n "${PROXY_VAR}" ]] && CurlRe "connect_monitor" "" "&connect_type=${PROXY_VAR}"
[[ -n "${UDP_VAR}" ]] && CurlRe "connect_monitor" "" "&connect_type=${UDP_VAR}"
