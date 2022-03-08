#!/bin/bash
# By : Wang
# History : 2021-09-26
# Description : NAT节点转发规则，接入转发到出口，接入192.168.254.2/30 出口192.168.254.1/30
# set -x
#
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

function AddInRule() {
    local interface_list
    local interface_ip
    interface_list=$(grep -E "eth|em|bond|ens|enp|wan|lan" /proc/net/dev | awk -F ":" 'OFS=":"{$NF="";print}' | sed s/:$//g | awk 'gsub(/^ *| *$/,"")')
    for i in ${interface_list[*]}; do
        interface_ip=$(ip a show dev "$i" | grep -v inet6 | grep -i -e inet -e link | grep -v 'ff\:ff' | awk '{print $2}' | awk -F[/] '{print $1}')
        for a in ${interface_ip[*]}; do
            [[ "${a}" == "192.168.254.2" ]] && continue
            iptables -t nat -C PREROUTING -d "$a"/32 -p udp -m multiport --dports 2086,2087,2088,8000 -m state --state NEW -m multiport --dports 2086,2087,2088,8000 -j DNAT --to-destination 192.168.254.1 || iptables -t nat -A PREROUTING -d "$a"/32 -p udp -m multiport --dports 2086,2087,2088,8000 -m state --state NEW -m multiport --dports 2086,2087,2088,8000 -j DNAT --to-destination 192.168.254.1
            iptables -t nat -C PREROUTING -d "$a"/32 -p tcp -m tcp --dport 9999 -m state --state NEW -j DNAT --to-destination 192.168.254.1:9999 || iptables -t nat -A PREROUTING -d "$a"/32 -p tcp -m tcp --dport 9999 -m state --state NEW -j DNAT --to-destination 192.168.254.1:9999
            iptables -t nat -C PREROUTING -d "$a"/32 -p tcp -m tcp --dport 2082 -m state --state NEW -j DNAT --to-destination 192.168.254.1:2082 || iptables -t nat -A PREROUTING -d "$a"/32 -p tcp -m tcp --dport 2082 -m state --state NEW -j DNAT --to-destination 192.168.254.1:2082
            iptables -t nat -C PREROUTING -d "$a"/32 -p udp -m udp --dport 10000 -m state --state NEW -j DNAT --to-destination 192.168.254.1:10000 || iptables -t nat -A PREROUTING -d "$a"/32 -p udp -m udp --dport 10000 -m state --state NEW -j DNAT --to-destination 192.168.254.1:10000
        done
        sleep 0.1
    done
    iptables -t mangle -C PREROUTING -i nat -j MARK --set-xmark 0x1e/0xffffffff || iptables -t mangle -A PREROUTING -i nat -j MARK --set-xmark 0x1e/0xffffffff
    ip rule add fwmark 30 table 2 pref 32700
    iptables -t nat -C POSTROUTING -j MASQUERADE || iptables -t nat -A POSTROUTING -j MASQUERADE
}
function AddOutRule() {
    local interface_list
    local interface_ip
    local num=10
    interface_list=$(grep -E "eth|em|bond|ens|enp|wan|lan" /proc/net/dev | awk -F ":" 'OFS=":"{$NF="";print}' | sed s/:$//g | awk 'gsub(/^ *| *$/,"")')
    for i in ${interface_list[*]}; do
        interface_ip=$(ip a show dev "$i" | grep -v inet6 | grep -i -e inet -e link | grep -v 'ff\:ff' | awk '{print $2}' | awk -F[/] '{print $1}')
        for a in ${interface_ip[*]}; do
            iptables -t nat -C PREROUTING -d "$a"/32 -i "$i" -j DNAT --to-destination 10.225.255."$num" || iptables -t nat -A PREROUTING -d "$a"/32 -i "$i" -j DNAT --to-destination 10.225.255."$num"
            iptables -t nat -C POSTROUTING -s 10.225.255."$num"/32 -o "$i" -j SNAT --to-source "$a" || iptables -t nat -A POSTROUTING -s 10.225.255."$num"/32 -o "$i" -j SNAT --to-source "$a"
        done
        sleep 0.1
    done
}

if dpkg -l ysnet-socks5 >/dev/null 2>&1; then
    AddOutRule
else
    # 仅存在隧道的时候生成192.168.254的DNAT规则
    ip link show nat >/dev/null 2>&1 && AddInRule
fi
