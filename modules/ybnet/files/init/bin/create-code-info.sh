#!/bin/bash
# By : Wang
# History : 2021-09-17
# Description : 生成节点信息;
#-------------: 10.18:增加pc和ak类型判断
# set -x
#
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

NODEID=$1
FILE="/etc/nodeinfo.ini"
PC_URL="https://new-node.yebaojiasu.com/api/v1/node/node_info/"
AK_URL="https://new-node.akspeedy.com/api/v1/node/node_info/"

ip rule l| grep -q "from all to 106.15.196.232 lookup 2" || ip rule add from all to 106.15.196.232 lookup 2 pref 32700
ip rule l| grep -q "from all to 47.100.69.96 lookup 2" || ip rule add from all to 47.100.69.96 lookup 2 pref 32700

# 强制转小写
typeset -l NODE_TYPE
NODE_TYPE="${1:-"pc"}"
NODEID=$2

if [[ "${NODE_TYPE}" == "pc" ]]; then
    if [[ -n "${NODEID}" ]]; then
        ARR=$(curl -s "${PC_URL}${NODEID}"| awk -F "[{}]" '{print $3}' | tr -d "\"" | tr "," "\n")
    else
        ARR=$(curl -s "${PC_URL}0"| awk -F "[{}]" '{print $3}' | tr -d "\"" | tr "," "\n")
    fi
elif [[ "${NODE_TYPE}" == "ak" ]]; then
    if [[ -n "${NODEID}" ]]; then
        ARR=$(curl -s "${AK_URL}${NODEID}"| awk -F "[{}]" '{print $3}' | tr -d "\"" | tr "," "\n")
    else
        ARR=$(curl -s "${AK_URL}0"| awk -F "[{}]" '{print $3}' | tr -d "\"" | tr "," "\n")
    fi
else
    echo "USAGE: create-code-info.sh [pc/PC/ak/AK(default: pc)] [pk_num(optional)] "
fi
[[ -n "${ARR}" ]] && echo "${ARR}" > "${FILE}"
