#!/bin/sh
ip1=`/usr/sbin/ip l|grep -e " em.*UP" -e " eth.*UP" -e "en.*UP"|awk -F ":" '{print$2}'|awk -F "@" '{print$1}'|sort|uniq|sed "s/ //g" |head -1`
ip2=`/usr/sbin/ip l|grep -e " em.*UP" -e " eth.*UP" -e "en.*UP"|awk -F ":" '{print$2}'|awk -F "@" '{print$1}'|sort|uniq|sed "s/ //g" |tail -1` 
fz=100
name=""
[ -f "/etc/nodeinfo.ini" ] && name=$(grep node_name /etc/nodeinfo.ini | awk -F ":" '{print $2}')
[ -n "${name}" ] || exit 0
#if [ "$1" = "" ];then    #判断后面是否有跟参数
#    echo -e "\n      use interface_name after the script,like \"script enp1s0f0\"...\n"
#    exit -1
#fi
 
#echo -e "\n      start monitoring the $1,press \"ctrl+c\" to stop"
#echo ----------------------------------------------------------
 
file=/proc/net/dev    #内核网卡信息文件
#while true
 #   do
    RX_bytes1=`cat $file|grep $ip1|sed 's/^ *//g'|awk -F'[ :]+' '{print $2}'`    #这里sed这一步为了同时兼容centos6和7
    TX_bytes1=`cat $file|grep $ip1|sed 's/^ *//g'|awk -F'[ :]+' '{print $10}'`
    RX_bytes2=`cat $file|grep $ip2|sed 's/^ *//g'|awk -F'[ :]+' '{print $2}'`    #这里sed这一步为了同时兼容centos6和7
    TX_bytes2=`cat $file|grep $ip2|sed 's/^ *//g'|awk -F'[ :]+' '{print $10}'`
    
    sleep 10
    RX_bytes_later1=`cat $file|grep $ip1|sed 's/^ *//g'|awk -F'[ :]+' '{print $2}'`
    TX_bytes_later1=`cat $file|grep $ip1|sed 's/^ *//g'|awk -F'[ :]+' '{print $10}'`
    RX_bytes_later2=`cat $file|grep $ip2|sed 's/^ *//g'|awk -F'[ :]+' '{print $2}'`
    TX_bytes_later2=`cat $file|grep $ip2|sed 's/^ *//g'|awk -F'[ :]+' '{print $10}'`
 
    #B*8/1024/1024=Mb
    speed_RX1=`echo "scale=2;($RX_bytes_later1 - $RX_bytes1)*8/1024/1024/10"|bc`
    speed_TX1=`echo "scale=2;($TX_bytes_later1 - $TX_bytes1)*8/1024/1024/10"|bc`
    speed_RX2=`echo "scale=2;($RX_bytes_later2 - $RX_bytes2)*8/1024/1024/10"|bc`
    speed_TX2=`echo "scale=2;($TX_bytes_later2 - $TX_bytes2)*8/1024/1024/10"|bc`
 
#    printf "$ip1 %-3s %-3.1f %-10s %-4s %-3.1f %-4s\n" IN: $speed_RX1 Mb/s OUT: $speed_TX1 Mb/s
#    printf "$ip2 %-3s %-3.1f %-10s %-4s %-3.1f %-4s\n" IN: $speed_RX2 Mb/s OUT: $speed_TX2 Mb/s
if [ `echo "$speed_RX1 > $fz" |bc` -eq 1 ] && [ `cat /root/speed_RX1.txt` -eq 1 ];then
       echo 0 > /root/speed_RX1.txt
       curl 'https://oapi.dingtalk.com/robot/send?access_token=afa3e588f1ea308cb0704d77b1a2cf72ee0ef133845a10e8c23bed61f6797ce0' -H 'Content-Type: application/json' -d "{\"msgtype\": \"text\", \"text\": {\"content\":  \" ${name} ${ip1} ${speed_RX1} 流入流量超过 ${fz}M\"}}"
    elif [ `echo "$speed_RX1 < $fz" |bc` -eq 1 ];then
       echo 1 > /root/speed_RX1.txt
fi
if [ `echo "$speed_TX1 > $fz" | bc` -eq 1 ] && [ `cat /root/speed_TX1.txt` -eq 1 ];then
       echo 0 > /root/speed_TX1.txt
       curl 'https://oapi.dingtalk.com/robot/send?access_token=afa3e588f1ea308cb0704d77b1a2cf72ee0ef133845a10e8c23bed61f6797ce0' -H 'Content-Type: application/json' -d "{\"msgtype\": \"text\", \"text\": {\"content\":  \" ${name} ${ip1} ${speed_TX1} 流出流量超过 ${fz}M\"}}"
    elif [ `echo "$speed_TX1 < $fz" |bc` -eq 1 ];then
       echo 1 > /root/speed_TX1.txt
fi
if [ `echo "$speed_RX2 > $fz" | bc` -eq 1 ] && [ `cat /root/speed_RX2.txt` -eq 1 ];then
       echo 0 > /root/speed_RX2.txt
       curl 'https://oapi.dingtalk.com/robot/send?access_token=afa3e588f1ea308cb0704d77b1a2cf72ee0ef133845a10e8c23bed61f6797ce0' -H 'Content-Type: application/json' -d "{\"msgtype\": \"text\", \"text\": {\"content\":  \" ${name} ${ip2} ${speed_RX2} 流入流量超过 ${fz}M\"}}"
    elif [ `echo "$speed_RX2 < $fz" |bc` -eq 1 ];then
       echo 1 > /root/speed_RX2.txt
fi
if [ `echo "$speed_TX2 > $fz" | bc` -eq 1 ] && [ `cat /root/speed_TX2.txt` -eq 1 ];then
       echo 0 > /root/speed_TX2.txt
       curl 'https://oapi.dingtalk.com/robot/send?access_token=afa3e588f1ea308cb0704d77b1a2cf72ee0ef133845a10e8c23bed61f6797ce0' -H 'Content-Type: application/json' -d "{\"msgtype\": \"text\", \"text\": {\"content\":  \" ${name} ${ip2} ${speed_TX2} 流出流量超过 ${fz}M\"}}"
    elif [ `echo "$speed_TX2 < $fz" |bc` -eq 1 ];then
       echo 1 > /root/speed_TX2.txt
fi
#done
