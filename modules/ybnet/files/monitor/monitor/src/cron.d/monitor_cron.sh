#!/bin/bash
# History: 2021-10-08
# Description: This script is for creating crontab.
# set -x
#
ip rule list | grep -q "from all to 101.132.115.68 lookup 2" || ip rule add from all to 101.132.115.68 lookup 2 pref 32700
ip rule list | grep -q "from all to 159.75.106.245 lookup 2" || ip rule add from all to 159.75.106.245 lookup 2 pref 32700
ip rule list | grep -q "from all to 139.196.172.164 lookup 2" || ip rule add from all to 139.196.172.164 lookup 2 pref 32700
ip rule list | grep -q "from all to 106.15.3.165 lookup 2" || ip rule add from all to 106.15.3.165 lookup 2 pref 32700
ip rule list | grep -q "from all to 106.75.173.115 lookup 2" || ip rule add from all to 106.75.173.115 lookup 2 pref 32700

#kill -9 $(pgrep python3)
#pip3 install -r /usr/local/bin/monitor/src/requirements.txt --index-url https://mirrors.aliyun.com/pypi/simple/
pgrep -alf system-exporter >/dev/null 2>&1 || nohup python3 /usr/local/bin/monitor/src/mods/plugins/system-exporter.py >/dev/null 2>&1 &

MONI_FILE="/etc/cron.d/monitor-cron"
MONI_FILE_SRC="/usr/local/bin/monitor/src/cron.d/monitor-cron"
[[ -f "${MONI_FILE}" ]] && MD5_NOW=$(md5sum "${MONI_FILE}" | cut -d" " -f1)
#MD5_NUM="1e59f2cf93aec190119610893659a1af"
MD5_NUM=$(md5sum "${MONI_FILE_SRC}" | cut -d" " -f1)
[[ -L "${MONI_FILE}" ]] || ln -s "${MONI_FILE_SRC}" "${MONI_FILE}" && exit 0
if [[ "${MD5_NOW}" != "${MD5_NUM}" ]]; then
    rm -rf "${MONI_FILE}"
    ln -s "${MONI_FILE_SRC}" "${MONI_FILE}"
fi
