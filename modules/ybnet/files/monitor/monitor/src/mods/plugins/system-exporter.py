#!/usr/bin/env python3
# -*- coding:utf-8 -*-

"""
  First Edit : 2021/11/05
  History : -
  By : Wang
  Description : Ysnet Node System Monitor Exporter
"""

import time
import schedule
import subprocess
import sys
from prometheus_client import Gauge, generate_latest, start_http_server
#from prometheus_client.core import CollectorRegistry
#registry = CollectorRegistry()

g = Gauge('ysnet_system_monitor', 'Ysnet Code System Monitor', [
          'report_time', 'code_ip', 'code_name', 'system_type', 'info'])


def get_shell_value():
    # 执行脚本输出结果
    subprocess.getoutput(
        'bash /usr/local/bin/monitor/start.sh monitor >/dev/null 2>&1')


def del_value():
    subprocess.getoutput('1>/tmp/system-monitor.conf 2>&1')  # 本次清空文本内容


def create_metrics():
    try:
        with open('/tmp/system-monitor.conf', 'r') as f:
            ffs = f.readlines()
            for lines in ffs:
                if lines:
                    line = lines.split()
                    my_time = line[1]
                    my_ip = line[3]
                    my_name = line[5]
                    my_type = line[7]
                    my_info = line[9]
                    # default : 1
                    value = 1
                    # $(date "+%Y/%m/%d-%H:%M:%S") ${myip} ${myname} ${mytype} ${info}
                    g.labels(report_time=my_time, code_ip=my_ip, code_name=my_name, system_type=my_type, info=my_info).set(value)
    except Exception:
        return False


if __name__ == '__main__':
    start_http_server(15427)  # 15427端口启动
    while True:
        get_shell_value()
        create_metrics()
        #schedule.every(24).hours.do(del_value)
        time.sleep(60)
        del_value()
