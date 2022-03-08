#!/bin/bash
# By : Wang
# History : 2019-8-28
# Description : Google检查，非20C机器安装proxy的机器如果返回200则报警
# set -x
#

function chk-google() {
    local local_ip
    local google_domain="www.google.com"
    local_ip=$(ifconfig eth0 | grep "inet addr" | awk '{print $2}' | awk -F: '{print $2}')
    if [[ ${local_ip} != *"122.10.163."* ]]; then
        source "${LIBS}/lib-chk-ip-for-domain.sh"
        source "${LIBS}/lib-send-alarm.sh"
        local google_result
        google_result=$(chk_ip_for_domain 404 ${google_domain} / 80 GOOGLE 2 5)
        if [[ -n "${google_result}" ]]; then
            # 发出报警, 记录异常日志
            send_alarm "domain=google&info=google_curl_err" "http://${URL_BASE}/google?code=google&node_ip=${MYIP}&timestamp=${MYTIME}&"
        fi
    fi
}
