#!/bin/bash
#:author: 王孟琦,2019-01-14
# SmokePing 报警数据上报
# Alertname="网络中断" / "丢包率>4%" / "延迟升高20%" / "延迟升高50%"
# Target="Chengdu[172.16.216.1]"
# Loss="loss: 0%, 0%, 0%, 0%, 0%, 45%, 40%"
# Rtt="rtt: 60ms, 10ms, 12ms, 30ms, 30ms, 60ms, 100ms, 120ms, 120ms, 30ms"
# Hostname="172.16.216.1"
source /usr/local/bin/monitor/src/libs/sys/lib-get-ip.sh
Alertname=$1
Target=$(echo "$2" | awk -F "." '{print $NF}')
Loss=$(echo "$3" | awk -F ", " '{print $NF}')
Rtt=$(echo "$4" | awk -F ", " '{print $NF}')
Hostname=$5
node_name=$(GetName)
node_ip=$(GetId)
time=$(date +'%Y-%m-%d %H:%M:%S')

curl_api() {
    messages=$(echo -e "时间：${time}\n节点名：$node_name\n节点IP：${node_ip}\n目标IP：${Hostname}\n报警内容：$Alertname")
    curl "https://oapi.dingtalk.com/robot/send?access_token=d84d062c1684203d3af20e594482c0776629fcef5ed309cb531de93bb762c5d9" -H 'Content-Type: application/json' -d "{\"msgtype\": \"text\", \"text\": {\"content\":  \"smkp: ${messages}\"}}"
}


# 判断延迟是否恢复
pro_output() {
        #判断文件内是否有ip，无则输入，有则退出
    if [[ $check_rtt -ne 0 ]];then
        [[ `grep $Hostname /var/ping_ip.txt | wc -l` -eq '0' ]] && echo "$Hostname:$check_rtt" >> /var/ping_ip.txt
    fi
    exit 0
}

if [[ "$Alertname" == *"延迟升高"* ]]; then
    # 取得 rtt 第一个参数为正常延迟
    check_rtt=$(echo $4 | awk -F ", " '{print $1}' | tr -cd '[0-9]')
    # 延迟报警条件: avg(current)/avg(historic) > 150/100 && rtt > 10
    [[ "$Alertname" == *50* ]] && ((${Rtt%m*} > 10)) && curl_api && pro_output
    [[ "$Alertname" == *20* ]] && ((${Rtt%m*} > 30)) && curl_api && pro_output
else
    # 网络中断及丢包率报警
    current_loss=$(echo $Loss | tr -cd '[0-9]')
    [[ $current_loss -eq 100 ]] && Alertname=$(echo "网络中断") && curl_api && exit 0
    [[ $current_loss -ne 100 ]] && curl_api && exit 0
fi