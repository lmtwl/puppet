#!/bin/bash
# History: 2021-10-08 系统资源监控
# Description: The main shell
# set -x

# 心跳
# [[ $(date +%M) == "00" ]] && source "${MODS}"/sys/monitor-heartbeat.sh &
#echo > /tmp/system-monitor.conf
# 磁盘报警
source "${MODS}"/sys/disk-alert.sh &
# 内存报警
source "${MODS}"/sys/mem-alert.sh &
# 进程报警
source "${MODS}"/sys/mod-process.sh &
# cpu报警
for ((i = 1; i < 2; i++)); do
    source "${MODS}"/sys/cpu-alert.sh &
    sleep 30
done

wait
