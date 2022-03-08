#!/bin/bash
# History: 2020-09-17
# Description: memory和swap报警
# set -x
#
source "${SYS}"/lib-curl.sh
source "${SYS}"/lib-mem.sh
source "${SYS}"/lib-get-mem-process.sh

MEM_OCCUPY=$(GetMemory)
if [[ -n "${MEM_OCCUPY}" ]]; then
    MEM_INFO=$(GetMemoryProcess)
    CurlRe "${MEM_OCCUPY}" "${MEM_INFO}"
fi
