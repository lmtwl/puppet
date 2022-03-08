#!/bin/bash
# History: 2021-10-08 
# Description: Just alarm!!
# set -x
#
function CurlRe() {
    source "${SYS}"/lib-get-ip.sh
    local myname
    local urlbase
    local mytime
    local myip 
    local mytype=${1:-""}
    local info=${2:-""}
    myname="$(GetName)"
    mytime=$(date "+%Y/%m/%d-%H:%M:%S")
    urlbase="https://oapi.dingtalk.com/robot/send?access_token=62d99756a13e294e47c67b78a0f06c65a5842774dca7e357fd66d4fc2b9a1712"
    myip=$(GetId)
    [[ -n "${myip}" ]] || return 0 
    curl "${urlbase}" -X POST -H 'Content-Type: application/json' -d "{\"msgtype\": \"text\", \"text\": {\"content\": {\"timestamp\": \"${mytime}\", \"system_type\": \"${mytype}\", \"node_ip\": \"${myip}\", \"alarm_info\": \"${info}\"}}}"
    echo -e "report_time ${mytime} code_ip ${myip} code_name ${myname} system_type ${mytype} info ${info}\n" >>/tmp/system-monitor.conf
}
