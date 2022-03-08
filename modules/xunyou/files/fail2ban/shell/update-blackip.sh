#!/bin/bash
ts=`date +%s`
php /usr/local/bin/update-blackip.php |awk -v t=$ts '{print t" " $0}'  >>/tmp/f2b.xunyou
fs=$(ls -l /tmp/f2b.xunyou|awk '{print $5}')
[ $fs -gt 29035857 ]&&rm /tmp/f2b.xunyou
