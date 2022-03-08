#!/bin/bash
# By : Wang
# History : 2021-09-27
# Description : For establishing tunnel between the two machines automatically.
# application scene: 建隧道 1.1.1.1|192.168.1.1|2.2.2.2|192.168.1.2
# shellcheck disable=SC2206,SC2207
# set -x
#
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
export PRESENT_PID=$$

trap 'exit 1' TERM

function ExitShell() {
    kill -s TERM "${PRESENT_PID}"
}

function GetLocalIp() {
    local network_interface
    local -a ip_list
    ip_list=()
    # 取网卡
    network_interface=$(grep -E "eth|em|bond|ens|eno|wan|lan|enp" /proc/net/dev | awk -F ":" 'OFS=":"{$NF="";print}' | sed s/:$//g | awk 'gsub(/^ *| *$/,"")')
    for a in ${network_interface[*]}; do
        # 取IP存数组
        myip=$(ip addr show dev "$a" | grep -v inet6 | grep -i -e inet -e link | grep -v 'ff\:ff' | awk '{print $2}' | awk -F[/] '{print $1}')
        ip_list[${#ip_list[*]}]=${myip}
        sleep 0.1
    done
    echo "${ip_list[*]}"
}

function InitializeAiNetplan() {
    local local_name=$1
    cat >"${TUNNEL_YAML}" <<EOF
network:
  version: 2
  ethernets:
    ${local_name}:
      dhcp4: true
      mtu: 1400 
EOF
}

function InitializeAiNetdev() {
    local local_ip=$1
    local remote_ip=$2
    local local_name=$3
    local local_type=${4:-"gretap"}
    cat >"${AI_NETDEV}" <<EOF
[Match]                                         
[NetDev]                                                  
Name=${local_name}
Kind=${local_type}
[Tunnel]
Independent=true
Local=${local_ip}
Remote=${remote_ip}
TTL=255 
EOF
}

function InitializeTunnelNetplanIn() {
    local local_ip=$1
    local remote_ip=$2
    local local_name=$3
    local local_type=${4:-"gretap"}
    cat >"${TUNNEL_YAML}" <<EOF
network:
  version: 2
  tunnels:
    ${local_name}:
      mode: ${local_type}
      local: ${local_ip}
      remote: ${remote_ip}
      addresses:
        - 192.168.254.2/30
      gateway4: 192.168.254.1
      mtu: 1400
EOF
}

function InitializeTunnelNetplanOut() {
    local local_ip=$1
    local remote_ip=$2
    local local_name=$3
    local local_type=${4:-"gretap"}
    cat >"${TUNNEL_YAML}" <<EOF
network:
  version: 2
  tunnels:
    ${local_name}:
      mode: ${local_type}
      local: ${local_ip}
      remote: ${remote_ip}
      addresses:
        - 192.168.254.1/30
      mtu: 1400
      routes:
        - to: 115.29.203.237
          via: 192.168.254.2
EOF
}

function CreateTunnel() {
    # 特殊：eth0:192.168.1.1 eth1:1.1.1.1
    # 1.1.1.1|192.168.1.1|2.2.2.2|192.168.1.2|1
    # 1.1.1.1||3.3.3.3||2
    # 本地IP 验证和分前后区
    local -a ip_arr
    # 匹配到的配置
    local -a conf_list
    # 定义隧道名
    local tunnel_name
    conf_list=()
    ip_arr=($(GetLocalIp))
    # 空文件退出
    [[ -s "${TARGETFILE}" ]] || ExitShell
    # 特殊情况多次匹配到需要去重
    conf_list=($(grep "tunnel" "${TARGETFILE}" | awk -F ":" '{print $2}'))
    # 文件不存在此机器的相关配置时退出
    [[ ${#conf_list[@]} -eq 0 ]] && ExitShell
    # transform : ip要求(私到私1 公到公2) 公网1 私网1 公网2 私网2 隧道类型
    # 1||192.168.1.1|2.2.2.2|192.168.2.2|gretap|1400
    # 2|1.1.1.1||2.2.2.2||gretap|1400
    cache_conf=(${conf_list//||/|null|})
    final_conf=(${cache_conf//|/ })
    # 定义名称
    requirement_ip=${final_conf[0]}
    public_ip_node=${final_conf[1]}
    private_ip_node=${final_conf[2]}
    public_ip_trunk=${final_conf[3]}
    private_ip_trunk=${final_conf[4]}
    tunnel_type=${final_conf[5]}
    # 隧道名称
    grep -q "node_type:2" "${TARGETFILE}" && tunnel_name="trunk"
    grep -q "node_type:4" "${TARGETFILE}" && tunnel_name="nat"
    grep -q "node_type:3" "${TARGETFILE}" && tunnel_name="ybnet"
    grep -q "node_type:5" "${TARGETFILE}" && tunnel_name="nat"
    [[ -n "${tunnel_name}" ]] || ExitShell
    # 建隧道
    # 私到私1
    if [[ ${requirement_ip} == 1 ]]; then
        # 前区匹配，接入机器
        if [[ "$(declare -p ip_arr)" =~ '['([0-9+])']="'${public_ip_node}'"' ]] || [[ "$(declare -p ip_arr)" =~ '['([0-9+])']="'${private_ip_node}'"' ]]; then
            # 主要为了异常处理和建隧道
            if [[ ${private_ip_node} == "null" ]] || [[ ${private_ip_trunk} == "null" ]]; then
                ExitShell
            else
                # 执行命令存下来单独执行
                # 接入 local 192.168.1.1 remote 192.168.2.2
                if [[ "${tunnel_name}" != "ybnet" ]]; then
                    InitializeTunnelNetplanIn "${private_ip_node}" "${private_ip_trunk}" "${tunnel_name}" "${tunnel_type}"
                    ip link show "${tunnel_name}" >/dev/null 2>&1 || {
                        CMD="${CMD}ip link add ${tunnel_name} type ${tunnel_type} remote ${private_ip_trunk} local ${private_ip_node}${LN}"
                        CMD="${CMD}ifconfig ${tunnel_name} 192.168.254.2/30 mtu 1400${LN}"
                    }
                elif [[ "${tunnel_name}" == "ybnet" ]]; then
                    # 环网
                    InitializeAiNetdev "${private_ip_node}" "${private_ip_trunk}" "${tunnel_name}" "${tunnel_type}"
                    InitializeAiNetplan "${tunnel_name}"
                    ip link show "${tunnel_name}" >/dev/null 2>&1 || {
                        CMD="${CMD}ip link add ${tunnel_name} type ${tunnel_type} remote ${private_ip_trunk} local ${private_ip_node} ttl 255${LN}"
                        CMD="${CMD}ifconfig ${tunnel_name} mtu 1400 up${LN}"
                        CMD="${CMD}dhclient ${tunnel_name} -v${LN}"
                    }
                else
                    ExitShell
                fi
            fi
        else
            # 后区匹配，汇聚/BGP
            if [[ ${private_ip_trunk} == "null" ]] || [[ ${private_ip_node} == "null" ]]; then
                ExitShell
            else
                # local 192.168.2.2 remote 192.168.1.1
                if [[ ${public_ip_node} != "null" ]]; then
                    InitializeTunnelNetplanOut "${private_ip_trunk}" "${private_ip_node}" "${tunnel_name}" "${tunnel_type}"
                    ip link show "${tunnel_name}" >/dev/null 2>&1 || {
                        CMD="${CMD}ip link add ${tunnel_name} type ${tunnel_type} remote ${private_ip_node} local ${private_ip_trunk}${LN}"
                        CMD="${CMD}ifconfig ${tunnel_name} 192.168.254.1/30 mtu 1400${LN}"
                        CMD="${CMD}ip route add 115.29.203.237/32 via 192.168.254.2${LN}"
                    }
                else
                    ExitShell
                fi
            fi
        fi
    fi
    # 公到公2
    if [[ ${requirement_ip} == 2 ]]; then
        # 前区匹配，接入机器
        if [[ "$(declare -p ip_arr)" =~ '['([0-9+])']="'${public_ip_node}'"' ]] || [[ "$(declare -p ip_arr)" =~ '['([0-9+])']="'${private_ip_node}'"' ]]; then
            ip link show "${tunnel_name}" >/dev/null 2>&1 || {
                if [[ ${private_ip_node} != "null" && ${public_ip_trunk} != "null" ]]; then
                    # local 192.168.1.1 remote 2.2.2.2
                    if [[ "${tunnel_name}" != "ybnet" ]]; then
                        InitializeTunnelNetplanIn "${private_ip_node}" "${public_ip_trunk}" "${tunnel_name}" "${tunnel_type}"
                        CMD="${CMD}ip link add ${tunnel_name} type ${tunnel_type} remote ${public_ip_trunk} local ${private_ip_node}${LN}"
                    elif [[ "${tunnel_name}" == "ybnet" ]]; then
                        InitializeAiNetdev "${private_ip_node}" "${public_ip_trunk}" "${tunnel_name}" "${tunnel_type}"
                        InitializeAiNetplan "${tunnel_name}"
                        CMD="${CMD}ip link add ${tunnel_name} type ${tunnel_type} remote ${public_ip_trunk} local ${private_ip_node}ttl 255${LN}"
                        CMD="${CMD}ifconfig ${tunnel_name} mtu 1400 up${LN}"
                        CMD="${CMD}dhclient ${tunnel_name} -v${LN}"
                    else
                        ExitShell
                    fi
                elif [[ ${public_ip_node} != "null" && ${public_ip_trunk} != "null" ]]; then
                    # local 1.1.1.1 remote 2.2.2.2
                    if [[ "${tunnel_name}" != "ybnet" ]]; then
                        InitializeTunnelNetplanIn "${public_ip_node}" "${public_ip_trunk}" "${tunnel_name}" "${tunnel_type}"
                        CMD="${CMD}ip link add ${tunnel_name} type ${tunnel_type} remote ${public_ip_trunk} local ${public_ip_node}${LN}"
                    elif [[ "${tunnel_name}" == "ybnet" ]]; then
                        InitializeAiNetdev "${public_ip_node}" "${public_ip_trunk}" "${tunnel_name}" "${tunnel_type}"
                        InitializeAiNetplan "${tunnel_name}"
                        CMD="${CMD}ip link add ${tunnel_name} type ${tunnel_type} remote ${public_ip_trunk} local ${public_ip_node} ttl 255${LN}"
                        CMD="${CMD}ifconfig ${tunnel_name} mtu 1400 up${LN}"
                        CMD="${CMD}dhclient ${tunnel_name} -v${LN}"
                    else
                        ExitShell
                    fi
                else
                    ExitShell
                fi
                CMD="${CMD}ifconfig ${tunnel_name} 192.168.254.2/30 mtu 1400${LN}"
            }
        else
            # 公网隧道，本地私网优先匹配
            if [[ ${public_ip_node} != "null" ]]; then
                ip link show "${tunnel_name}" >/dev/null 2>&1 || {
                    if [[ ${private_ip_trunk} != "null" ]]; then
                        # local 192.168.2.2 remote 1.1.1.1
                        InitializeTunnelNetplanOut "${private_ip_trunk}" "${public_ip_node}" "${tunnel_name}" "${tunnel_type}"
                        CMD="${CMD}ip link add ${tunnel_name} type ${tunnel_type} remote ${public_ip_node} local ${private_ip_trunk}${LN}"
                    elif [[ ${public_ip_trunk} != "null" ]]; then
                        # local 2.2.2.2 remote 1.1.1.1
                        InitializeTunnelNetplanOut "${public_ip_trunk}" "${public_ip_node}" "${tunnel_name}" "${tunnel_type}"
                        CMD="${CMD}ip link add ${tunnel_name} type ${tunnel_type} remote ${public_ip_node} local ${public_ip_trunk}${LN}"
                    else
                        ExitShell
                    fi
                    CMD="${CMD}ifconfig ${tunnel_name} 192.168.254.1/30 mtu 1400${LN}"
                    CMD="${CMD}route add 115.29.203.237 gw 192.168.254.2${LN}"
                }
            else
                ExitShell
            fi
        fi
    fi
}

# 目标文件
TARGETFILE="/etc/nodeinfo.ini"
# 隧道文件
TUNNEL_YAML="/etc/netplan/90-tunnel.yaml"
AI_NETDEV="/etc/systemd/network/ybnet.netdev"
# 定义变量
LN='\n'
CMD=""
# 生成命令执行
CreateTunnel
echo -e "${CMD}" | bash
