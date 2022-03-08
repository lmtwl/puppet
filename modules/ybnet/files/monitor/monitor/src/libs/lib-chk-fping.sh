#!/bin/bash
# author: Wang, Fufu, 2019-03-29
# fping 指定 IP, 失败时返回日志内容
# usage: chk_fping IP 其他内容
# set -x
#
function chk_fping() {
    local my_ip=${1:-""}
    local my_domain=$2
    local my_platform=$3

    # 参数检查
    [[ -z "${my_ip}" ]] && return 1

    # 存活检查
    fping -qr3 "${my_ip}" || fping -qr3 "${my_ip}" || echo "dstip=${my_ip}&domain=${my_domain}&platform=${my_platform}&info=fping_unreachable"
}
