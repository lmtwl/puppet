#!/bin/bash
# History: 202-09-27
# Description: proxy规则监控
# set -x
#
source "${SYS}"/lib-curl.sh
source "${SYS}"/lib-get-proxy-rule.sh

RULE_VAR=$(GetProxyRule)
[[ -n "${RULE_VAR}" ]] && CurlRe "proxy_rule" "proxy_rule_not_exist" ""
