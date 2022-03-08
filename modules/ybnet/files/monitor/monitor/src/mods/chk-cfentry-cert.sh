#!/bin/bash
# History: 2020-03-04
# By : Wang
# Description: cfentry域名检查
# set -x
#
source "${LIBS}/lib-send-alarm.sh"

function chk_cfentry() {
    local cfentry_domain="prod-live-cfentry.playbattlegrounds.com"
    local result_cf
    result_cf=$(curl -k --resolve ${cfentry_domain}:443:155.89.15.3 https://${cfentry_domain} -m 5 -s)
    local chk_result_cf='{"health":true}'
    if [[ "${result_cf}" != "${chk_result_cf}" ]]; then
        send_alarm "dstip=155.89.15.3&domain=${cfentry_domain}&platform=pubg&info=cfentry_curl_failed" "${API}"
    fi
}
