#!/bin/bash
# author: Fufu, 2019-03-29
# 通用检测方法: 加载配置, 执行检测, 写入日志, 发出报警
# usage: chk_common_main lib_func_name conf_file running_n sleep_n
# usage: chk_common_main chk_fping "${SRC}/chk-pubg-fping.conf" 1 2
# set -x
#
function chk_common_async() {
    # 执行域名检查, 成功时结果为空
    local result 
    result=$("$@")
    if [[ -n "${result}" ]]; then
        # 发出报警, 记录异常日志
        send_alarm "${result}" "${API}"
    fi
}

# 主执行程序
function chk_common_main() {
    # libs 脚本文件名为短横线, 函数名为下划线
    local lib_file="${LIBS}/lib-${1//_/-}.sh"
    local lib_func=$1

    # 检查类库文件
    if [[ ! -f "${lib_file}" ]]; then
        echo "Check lib_file: ${lib_file}" && usage
        return 1
    fi

    # 引入资源
    source "${LIBS}/lib-send-alarm.sh"
    source "${LIBS}/lib-exec-conf-async.sh"
    source "${lib_file}"

    # 检查被调用函数
    if [[ $(type -t "${lib_func}") != "function" ]]; then
        echo "Check function: ${lib_func}" && usage
        return 1
    fi

    # 执行检测
    shift
    exec_conf_async "chk_common_async ${lib_func}" "$@"

    # 心跳日志
    # [[ $(date +%M) == "00" ]] && heart_monitor
}
