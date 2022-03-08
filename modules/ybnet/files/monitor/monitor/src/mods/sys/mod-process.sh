#!/bin/bash
# History: 2019-08-23
# -------: 2020-09-优化
# Description: This script is for checking process of nodes such as vppp,sock,etc.
# set -x
#
source "${SYS}"/lib-curl.sh
source "${SYS}"/lib-get-mode.sh

L2TP_VAR=$(ProcessTwo)
SOCKS_VAR=$(ProcessFour)
IKEV_VAR=$(ProcessFive)
PINGOK_VAR=$(ProcessPing)
ECHO_VAR=$(ProcessEcho)
PROXY_VAR=$(ProcessProxy)

ALL_MODE=$(echo "${L2TP_VAR}${SOCKS_VAR}${IKEV_VAR}${PINGOK_VAR}${ECHO_VAR}${PROXY_VAR}" | tr -d '\n')

# 报警判断，参数存在则处理报警
[[ -n "${ALL_MODE}" ]] && CurlRe "process掉线" "${ALL_MODE}"
