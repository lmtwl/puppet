#!/bin/bash
# By : Wang
# History : 2021-11-03
# Description : Send the version of each ysnet-*** package;
# set -x
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

# 10 9 * * * root /usr/local/bin/monitor/package-check-send.sh

source /usr/local/bin/monitor/src/libs/sys/lib-get-ip.sh
mytime=$(date "+%Y/%m/%d-%H:%M:%S")
NODEIP="$(GetId)"
NODENAME="$(GetName)"
PACKAGE_LIST=$(dpkg -l | grep "ysnet" | awk '{print $2}' | grep "^ysnet")
ARR=""

function random_second() {
    min=$1
    max=$(($2 - min + 1))
    num=$(date +%s%N)
    echo $((num % max + min))
}
function pack_collect() {
    local package_ver
    for i in ${PACKAGE_LIST}; do
        package_ver=$(dpkg -l "${i}" | tail -1 | awk '{print $3}')
        ARR="${ARR}code_ip ${NODEIP} code_name ${NODENAME} report_time ${mytime} package_name ${i} package_version ${package_ver} 1\n"
    done
    echo -e "${ARR}"
}

#SLEEPTIME=$(random_second 1 60)
#sleep "${SLEEPTIME}"

#cat <<EOF | curl --data-binary @- http://1.14.106.123:9091/metrics/job/test_job/instance/test_ysnet_package_report
#$(pack_collect)
#EOF

cat >/tmp/package-report.conf <<EOF
$(pack_collect)
EOF
