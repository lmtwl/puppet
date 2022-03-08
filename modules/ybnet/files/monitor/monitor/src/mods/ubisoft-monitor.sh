#!/bin/bash
# History: 2020-10-10 
# By : Wang
# Description: 育碧服务检查
# set -x
#

# 安装proxy/nproxy/rproxy任意一个就检测
dpkg -l | grep -qE "xunyou-proxy|xunyou-rproxy|nproxy" || return 0

function chk_ubi_service() {
    local ubi_domain="public-ubiservices.ubi.com"
    local ubi_result="dstip=155.89.11.16&domain=${ubi_domain}&platform=ubisoft&info=cannot_get_cert"
    source "${LIBS}/lib-logger.sh"
    curl -I -kvs --resolve ${ubi_domain}:443:155.89.11.16 https://${ubi_domain}/ -o /dev/null 1>&2 2>/tmp/chk_ubi_service.logger
    grep -q "CN=\*.ubi.com" /tmp/chk_ubi_service.logger || {
        send_alarm "${ubi_result}" "${API}"
    }
}

chk_ubi_service