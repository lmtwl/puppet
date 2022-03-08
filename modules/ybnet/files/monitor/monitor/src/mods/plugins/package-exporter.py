#!/usr/bin/env python3
# -*- coding:utf-8 -*-

"""
  First Edit : 2021/11/05
  History : -
  By : Wang
  Description : Report md5sum of dnsmasq configure file
"""

import time
import schedule
import subprocess
import sys
from prometheus_client import Gauge, generate_latest, start_http_server
#from prometheus_client.core import CollectorRegistry
#registry = CollectorRegistry()

g = Gauge('ysnet_package_report', 'Package Report Provider', [
          'code_ip', 'code_name', 'package_name', 'package_version'])


def get_shell_valve():
    # 执行脚本输出结果
    subprocess.getoutput(
        'bash /usr/local/bin/monitor/src/mods/plugins/package-check-send.sh')


def del_value():
    subprocess.getoutput('1>/tmp/package-report.conf 2>&1')  # 本次清空文本内容


def create_metrics():
    try:
        with open('/tmp/package-report.conf', 'r') as f:
            ffs = f.readlines()
            for lines in ffs:
                if lines:
                    line = lines.split()
                    my_ip = line[1]
                    my_name = line[3]
                    my_time = line[5]
                    my_package_name = line[7]
                    my_package_version = line[9]
                    valve = line[10]
                    g.labels(code_ip=my_ip, code_name=my_name, package_name=my_package_name, package_version=my_package_version).set(valve)
    except Exception:
        return False


if __name__ == '__main__':
    start_http_server(15426)  # 15426端口启动
    while True:
        get_shell_valve()
        create_metrics()
        #schedule.every(24).hours.do(del_value)
        time.sleep(28800)
        del_value()
