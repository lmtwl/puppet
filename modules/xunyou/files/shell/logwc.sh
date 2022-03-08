#!/bin/bash
#set -x
mu=/opt/nginx/log
mkdir -p $mu
declare -a filename

filename=(`find /var/log/nginx/ -name "access.json*.gz" -mtime -10`);
[ ! -n "$filename" ] &&{ echo "No such file\n";exit 0 ;}

for ((j=0;j<${#filename[@]};j++));do
        tdata=$(echo ${filename[$j]} |grep -oP '(?<=-)[0-9]+')
        ((i=$tdata-1))
        if [ ! -f "$mu/$i" ]; then

        zcat ${filename[$j]} |awk '{print $4}' |sort |uniq -c | sort -nr | egrep -v -i -e "*.png|*.gif|*.js|*.css|*.ico" |awk 'NR==1;NR>1&&($1>10)' >$mu/$i

        fi


done
