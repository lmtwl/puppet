#!/bin/bash
# History: 2020-9-16
# Description: cpu报警
# set -x
#
source "${SYS}"/lib-curl.sh
source "${SYS}"/lib-cpu.sh
source "${SYS}"/lib-get-cpu-process.sh

CPU_OCCUPY=$(GetCpu)
if [[ -n "${CPU_OCCUPY}" ]]; then
    CPU_INFO=$(GetCpuProcess)
    CurlRe "${CPU_OCCUPY}" "${CPU_INFO}"
fi
