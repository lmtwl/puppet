#!/bin/bash
#cd /var/log/nginx
export RSYNC_PASSWORD=redhat2016
data_a=$(date +"%Y-%m-%d" -d "-1day")
#rsync -avzur  --update  --bwlimit=1000 log admin@42.62.106.183::log/$(hostname)/
/usr/bin/rsync -avzur  --update  --bwlimit=1000  /var/log/nginx/access.json*gz admin@112.125.90.168::log/$(hostname)/
