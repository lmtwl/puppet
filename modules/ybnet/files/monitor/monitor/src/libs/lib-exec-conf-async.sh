#!/bin/bash
# author: Fufu, 2019-03-28
# 调用相应的函数处理配置文件内容
# usage: exec_conf_async "func_name func_args" conf-file running_n sleep_n
# usage: exec_conf_async chk_domain_async ./src/chk-pubg-domain.conf 10 2
# usage: exec_conf_async 'chk_common_async chk_fping' ./src/chk-pubg-fping.conf 10 2
# set -x
#
function exec_conf_async() {
    local -a func_args=($1)
    local conf_file=${2:-"${SRC}/${M_NAME}.conf"}
    local -i running_n=${3:-20}
    local -i sleep_n=${4:-1}

    # 检查被调用函数
    if [[ $(type -t "${func_args[0]}") != "function" ]]; then
        echo "Check function: ${func_args[@]}" && usage
        return 1
    fi

    # 检查配置文件
    if [[ ! -f "${conf_file}" ]]; then
        echo "Check conf_file: ${conf_file}" && usage
        return 1
    fi

    # 循环调用函数
    local i=1
    while read conf; do
        # 排除空行和注释行
        [[ -z "${conf}" ]] || [[ "${conf:0:1}" == "#" ]] && continue
        # 反射
        eval "${func_args[@]} ${conf} &"
        # 每 20 个进程等待 1 秒
        ((running_n > 0)) && [[ $((i % running_n)) == 0 ]] && sleep "${sleep_n}"
        ((i++))
    done <"${conf_file}"
    wait
}
