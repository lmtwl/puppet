#!/bin/bash
# History: 2020-9-25
# Description: 磁盘报警
# set -x
#
source "${SYS}"/lib-curl.sh
source "${SYS}"/lib-disk.sh

DISK_OCCUPY=$(GetDisk)
if [[ -n "${DISK_OCCUPY}" ]]; then
    CurlRe "${DISK_OCCUPY}" "${DISK_OCCUPY}"
fi