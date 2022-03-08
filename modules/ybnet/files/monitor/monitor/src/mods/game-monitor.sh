#!/bin/bash
# author: Wang 2019-08-26
# 绝地求生全业务监控
# usage: ./start.sh pubg-monitor
# set -x
# History: 跳转页监控定义function；新增nproxy重启；
# shellcheck disable=SC1090
#

source "${SYS}"/lib-get-ip.sh
NODEID=$(GetId)

# 国内和回国不检测
if grep -q -E "node_type:5|node_type:1" /etc/nodeinfo.ini; then
    return 0
elif grep -q -E "node_type:2|node_type:4" /etc/nodeinfo.ini; then
    grep -q gretap /etc/nodeinfo.ini && dpkg -l ysnet-proxy>/dev/null 2>&1 || return 0
else
    :
fi

# 引入通用检测方法
source "${LIBS}/lib-chk-common-main.sh"
# 引入大厅跳转页
# source "${MODS}"/chk-pubg-jump.sh
# 谷歌域名检查
# source "${MODS}"/chk-google-domain.sh
# cfentry域名证书检查
# source "${MODS}"/chk-cfentry-cert.sh

# 检测 PUBG 大厅域名等
chk_common_main chk_ip_for_domain "${SRC}/chk-game-domain.conf" &

# fping blhp.www.vivox.com
# chk_common_main chk_fping "${SRC}/chk-game-fping.conf" &

# telnet/nc prod-live-entry
# chk_common_main chk_nc "${SRC}/chk-game-nc.conf" &

# cfentry
# chk_cfentry &

# 跳转页检测 
# chk-pubg-jump &

# Google检查
# chk-google &

wait

