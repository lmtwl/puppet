#!/bin/bash
# History: 2020-09-25
# Description: 检查xunyou-proxy/rproxy/nproxy的iptables规则
# set -x
#
function GetProxyRule() {
    local judge_proxy=0
    local num_proxy_deb
    num_proxy_deb=$(dpkg -l | grep -cE "xunyou-proxy|nproxy|rproxy")
    if ((num_proxy_deb > 1)); then
        echo "xunyou-proxy"
    else
        if ((num_proxy_deb == 1)); then
        grep -q "14.04" /etc/issue && {
            echo "iptables -t nat -C PREROUTING -p tcp -m multiport --dports 80,443 -m mark --mark 0x0 -j DNAT --to-destination 172.31.255.254:8000" | bash >/dev/null 2>&1 || judge_proxy=1
            echo "iptables -t nat -C OUTPUT -p tcp -m multiport --dports 80,443 -m mark --mark 0x0 -j DNAT --to-destination 172.31.255.254:8000" | bash >/dev/null 2>&1 || judge_proxy=1
        }
        grep -q "20.04" /etc/issue && {
            echo "iptables -t nat -C NAT_PREROUTING_DNAT_PROXY -p tcp -m multiport --dports 80,443 -m mark --mark 0x0 -j DNAT --to-destination 172.31.255.254:8000" | bash >/dev/null 2>&1 || judge_proxy=1
            echo "iptables -t nat -C NAT_OUTPUT_DNAT_PROXY -p tcp -m multiport --dports 80,443 -m mark --mark 0x0 -j DNAT --to-destination 172.31.255.254:8000" | bash >/dev/null 2>&1 || judge_proxy=1
        }
        ((judge_proxy == 1)) && echo "proxy-rule"
        fi
    fi
}
