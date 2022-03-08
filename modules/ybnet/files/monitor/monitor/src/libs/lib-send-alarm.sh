#!/bin/bash
# author: Wang 2020-09-30
# 发出报警
# usage: send_alarm "报警内容" "API_URL"
# set -x
# History: 新增上报机器ip； 新增服务心跳接口
#
source "${SYS}"/lib-get-ip.sh
MYIP=$(GetId)
MYNAME=$(GetName)
MYTIME=$(date +%s)
URL_BASE="https://oapi.dingtalk.com/robot/send?access_token=6589423c2116634cd2b99a55b130dd15e9bf7cc3ee955d0a19fd5fa4d1ed20df"

function send_alarm() {
    local send_info=${1// /:}
    # "${my_domain}&${my_platform}&${http_code}&${result_code}"
    local alert_domain
    local alert_platform
    local standard_code
    local result_code
    [[ -n "${MYIP}" ]] || return 0
    alert_domain=$(echo "${send_info}" | awk -F "&" '{print $1}')
    alert_platform=$(echo "${send_info}" | awk -F "&" '{print $2}')
    standard_code=$(echo "${send_info}" | awk -F "&" '{print $3}')
    result_code=$(echo "${send_info}" | awk -F "&" '{print $4}')
    # 调用重启
    # [[ $(type -t send_alarm_before) == "function" ]] && send_alarm_before "$@"

    local api_url=${2:-"${URL_BASE}"}
    curl "${api_url}" -X POST -H 'Content-Type: application/json' -d "{\"msgtype\": \"text\", \"text\": {\"content\": {\"timestamp\": \"${MYTIME}\", \"domain\": \"${alert_domain}\", \"node_ip\": \"${MYIP}\", \"node_name\": \"${MYNAME}\", \"alarm_info\": \"${alert_domain}访问异常,理论返回码${standard_code},当前返回码${result_code}\"}}}" >/dev/null 2>&1
}

function heart_monitor() {
    local heart_api
    heart_api="http://${URL_BASE}/service_monitor?code=service_monitor&node_ip=${MYIP}&service_type=game_domain&timestamp=${MYTIME}&info=game_domain_exec_SUCCESS"
    # curl "${heart_api}" >/dev/null 2>&1
}
