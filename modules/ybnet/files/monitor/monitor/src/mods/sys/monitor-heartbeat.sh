#!/bin/bash
# History: 2020-09-30
# Description: monitor heart .
# set -x
#
source "${SYS}"/lib-curl.sh

CurlRe "service_monitor" "monitor_exec_SUCCESS" "&service_type=monitor"
