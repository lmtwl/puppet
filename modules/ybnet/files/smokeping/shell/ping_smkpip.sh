#!/bin/bash
#By Wang
#2018-12-13
#检查/var/ping_ip.txt中smokeping中延迟升高的ip

source /usr/local/bin/monitor/src/libs/sys/lib-get-ip.sh
node_name=$(GetName)
node_ip=$(GetId)
time=$(date +'%Y-%m-%d %H:%M:%S')
FILE="/var/ping_ip.txt"

function chk_rtt() {
    local current_rtt
    local result_judge
    current_rtt=$(ping "$1" -c 3 | grep avg | awk -F "/" '{print $5}')
    result_judge=$(echo "scale=2;${current_rtt}/$2" | bc | awk '{printf "%.2f", $0}')
    [[ $(expr "${result_judge}" \< 1.2) -eq 1 ]] && sed -i /"$1"/d "${FILE}"
}

[[ -f "${FILE}" ]] || exit 0
while read -r Line; do
    check_ip=$(echo "${Line}" | awk -F ":" '{print $1}')
    [[ -n "${check_ip}" ]] || continue
    check_rtt=$(echo "${Line}" | awk -F ":" '{print $2}')
    chk_rtt "${check_ip}" "${check_rtt}" &
done <"${FILE}"
wait
arr=$(awk -F ":" '{print $1}' "${FILE}")
[[ -n "${arr}" ]] && {
    messages=$(echo -e "时间：${time}\n节点名：${node_name}\n节点IP：${node_ip}\n报警内容：延迟持续升高\n${arr}")
    curl "https://oapi.dingtalk.com/robot/send?access_token=d84d062c1684203d3af20e594482c0776629fcef5ed309cb531de93bb762c5d9" -H 'Content-Type: application/json' -d "{\"msgtype\": \"text\", \"text\": {\"content\":\"smkp: ${messages}\"}}"
}
