#!/bin/bash
# set -x
[[ -f "/opt/ysnet/init/etc/localfw" ]] && iptables-restore < /opt/ysnet/init/etc/localfw
