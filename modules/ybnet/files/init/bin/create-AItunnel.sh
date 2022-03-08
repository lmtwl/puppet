#!/bin/bash
# By : Wang
# History : 2021-09-26
# Description : 生成环网隧道;
# set -x
#
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

AI_NETDEV="/etc/systemd/network/ybnet.netdev"
TUNNEL_YAML="/etc/netplan/90-tunnel.yaml"
NODE_CONF="/etc/nodeinfo.ini"
[[ -f "${NODE_CONF}" ]] || exit 0

function InitializeAiNetplan() {
    cat >"${TUNNEL_YAML}" <<EOF
network:
  version: 2
  ethernets:
    ybnet:
      addresses:
        - ${TUNNEL_IP}
      gateway4: ${TUNNEL_GATEWAY}
      mtu: 1400 
EOF
}

function InitializeAiNetdev() {
    cat >"${AI_NETDEV}" <<EOF
[Match]                                         
[NetDev]                                                  
Name=ybnet
Kind=gretap
[Tunnel]
Independent=true
Local=${LOCAL_IP}
Remote=${BGP_IP}
TTL=255 
EOF
}

if grep -q "node_type:3" "${NODE_CONF}" >/dev/null 2>&1; then
    read -rp "请输入BGP IP(如13.124.1.1)：" BGP_IP
    read -rp "请输入本地网卡IP(如172.18.9.25)：" LOCAL_IP
    read -rp "请输入隧道IP(如10.6.16.226/31)：" TUNNEL_IP
    read -rp "请输入隧道网关(如10.6.16.227)：" TUNNEL_GATEWAY
    InitializeAiNetplan
    InitializeAiNetdev
    echo "ip link add ybnet type gretap remote ${BGP_IP} local ${LOCAL_IP} ttl 255" | bash
    echo "ifconfig ybnet ${TUNNEL_IP} mtu 1400" | bash
fi
