#!/bin/bash
eth_name=$(ip r l t 2 | awk '{print $5}')
[[ -n "${eth_name}" ]] || echo "未获取到table 2"
if ip -d link show "${eth_name}" | grep -q "vlan protocol"; then
    echo -e "存在vlan，请手动写入\n- from: 0.0.0.0/0\n  mark: 30\n  table: 2\n  priority: 32700"
else
    if [[ ! -f /etc/netplan/91-fmark.yaml ]]; then
        cat >/etc/netplan/91-fmark.yaml <<EOF
network:
  version: 2
  ethernets:
    ${eth_name}:
      routing-policy:
        - from: 0.0.0.0/0
          mark: 30
          table: 2
          priority: 32700
EOF
    fi
fi
