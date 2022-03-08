#!/bin/bash
# History: 2020-7-6
# 根据指定 IP 检查 URL 状态码, 类似写 HOSTS 效果
# usage: chk_ip_for_domain 正确的状态码 域名 URI 端口 检测次数 指定 IP
# usage: chk_ip_for_domain 200 www.baidu.com /act.shtml?123 80 3 118.116.6.133
# set -x
#
function chk_ip_for_domain() {
    # 200 www.baidu.com /act.shtml?123 80 3 118.116.6.133
    (($# < 1)) && return 1
    local http_code=$1
    local my_domain=${2:-""}
    local uri=${3:-""}
    local -i port=${4:-443}
    local my_platform=$5
    local -i count=${6:-1}
    local time_out=${7:-5}
    local ip=${8:-""}
    ((count < 1)) && count=1

    # curl 参数
    local result_code
    local curl_cmd="curl -X GET -ksI -m ${time_out} -o /dev/null -w %{http_code}"
    local scheme="http://"
    ((port == 443)) && scheme="https://"

    for i in $(seq 1 $count); do
        # 重试时延迟 1 秒
        ((i > 1)) && sleep 1
        if [[ -n "${ip}" ]]; then
            # 指定 IP 访问
            result_code=$(${curl_cmd} --resolve "${my_domain}:${port}:${ip}" "${scheme}${my_domain}${uri}")
        else
            # 直接域名访问
            result_code=$(${curl_cmd} "${scheme}${my_domain}${uri}")
        fi
        [[ "${http_code}" == "${result_code}" ]] && break
    done

    # 返回错误日志
    [[ "${http_code}" != "${result_code}" ]] &&
        echo "${my_domain}&${my_platform}&${http_code}&${result_code}"
}
