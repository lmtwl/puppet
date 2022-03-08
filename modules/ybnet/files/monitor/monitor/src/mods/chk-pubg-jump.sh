#!/bin/bash
# By : Fu , Wang
# History : 2019-8-26
# Description : 吃鸡大厅跳转页监控
# set -x 
#

# 获取吃鸡大厅跳转页url
function get_pubg_jump_url
{
    for i in $(seq 1 5); do
        ((i > 1)) && sleep 0.2
        app_url=$(curl -skm5 --resolve "${pubg_domain}:443:${pubg_host}" "https://${pubg_domain}/index.html" |
            grep location.href | awk -F '"' '{print $2}')
        [[ -n "${app_url}" ]] && break
    done
    echo "${app_url}"
}

# 引入通用方法检查跳转页返回码
function chk-pubg-jump
{
    # 吃鸡大厅域名, 指定 IP 及 报警 API
    local pubg_domain="prod-live-front.playbattlegrounds.com"
    local pubg_host="52.84.49.118"

    # 未获取到大厅跳转 URL 时不做操作
    local app_url
    app_url=$(get_pubg_jump_url)
    [[ -z "${app_url}" ]] && return 0

    local result
    source "${LIBS}/lib-chk-ip-for-domain.sh"
    source "${LIBS}/lib-send-alarm.sh"
    result=$(chk_ip_for_domain 200 "${pubg_domain}" "${app_url}" 443 PUBG 5 5 "${pubg_host}")
    if [[ -n "${result}" ]]; then
        # 发出报警, 记录异常日志
        send_alarm "${result}" "${API}"
    fi
}
