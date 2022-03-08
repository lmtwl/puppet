#!/bin/bash
node=""
[[ -f "/etc/nodeinfo.ini" ]] && node=$(grep node_name /etc/nodeinfo.ini | awk -F ":" '{print $2}')
[[ -n "${node}" ]] || exit 0
vppp_ikev2(){
ikev2=`ps -ef|grep vppp_ikev2|grep -v grep|wc -l`
echo "ikev2正常计数1"
echo "检测ikev2数量$ikev2"
if [ $ikev2 -lt 1 ];then
   curl 'https://oapi.dingtalk.com/robot/send?access_token=89a01c02f1d866f66d86415ee47e8895c626f512e3928a83daa99685babc72fd' -H 'Content-Type: application/json' -d "{\"msgtype\": \"text\", \"text\": {\"content\":  \" 野豹$node 监控ikev2程序掉线\"}}"
fi
}
vppp_sock5(){
vpppsocks5=`ps -ef|grep vppp_sock5|grep -v grep|wc -l`
echo "vppp_sock5正常计数1"
echo "检测vppp_socks数量$vpppsocks5"
if [ $vpppsocks5 -lt 1 ];then
   curl 'https://oapi.dingtalk.com/robot/send?access_token=89a01c02f1d866f66d86415ee47e8895c626f512e3928a83daa99685babc72fd' -H 'Content-Type: application/json' -d "{\"msgtype\": \"text\", \"text\": {\"content\":  \" 野豹$node 监控vppp_socks5程序掉线\"}}"
fi
}
socks5udp(){
socks5udp=`ps -ef|grep socks5udp|grep -v grep|wc -l`
echo "socks5udp正常计数1"
echo "检测socks5udp数量$socks5udp"
if [ $socks5udp -lt 1 ];then
	curl 'https://oapi.dingtalk.com/robot/send?access_token=89a01c02f1d866f66d86415ee47e8895c626f512e3928a83daa99685babc72fd' -H 'Content-Type: application/json' -d "{\"msgtype\": \"text\", \"text\": {\"content\":  \" 野豹$node 监控socks5udp程序掉线\"}}"
fi

}
socks5(){
#socks5=`ps -ef|grep socks5|grep 9999 |wc -l`
socks5=$(ps -ef | grep -c "/opt/ysnet/socks5/bin/socks5$")
echo "socks5正常计数1"
echo "检测socks5数量$socks5"
if [ $socks5 -lt 1 ];then
     curl 'https://oapi.dingtalk.com/robot/send?access_token=89a01c02f1d866f66d86415ee47e8895c626f512e3928a83daa99685babc72fd' -H 'Content-Type: application/json' -d "{\"msgtype\": \"text\", \"text\": {\"content\":  \" 野豹$node 监控socks5_9999程序掉线\"}}"
fi

}
socks5_plur(){
	socks5_plur=`ps -ef|grep socks5_plur|grep -v grep|wc -l`
	echo "socks5_plur正常计数1"
	echo "检测socks5_plur数量$socks5_plur"
	if [ $socks5_plur -lt 1 ];then
		     curl 'https://oapi.dingtalk.com/robot/send?access_token=89a01c02f1d866f66d86415ee47e8895c626f512e3928a83daa99685babc72fd' -H 'Content-Type: application/json' -d "{\"msgtype\": \"text\", \"text\": {\"content\":  \" 野豹$node 监控socks5_plur程序掉线\"}}"
	fi

}
l2tpns(){
#l2tpns=`cat /etc/rc.local |awk -F '=' '{print $2}' |grep .|wc -l`
#network=`expr $l2tpns / 2`
#vppp=`expr $network + 2`
l2=`ps -ef|grep l2tpns|grep -v grep|wc -l`
echo "l2tpns正常计数2"
echo "检测l2tpns数量$l2"
if [ $l2 -lt 2 ];then
	  curl 'https://oapi.dingtalk.com/robot/send?access_token=89a01c02f1d866f66d86415ee47e8895c626f512e3928a83daa99685babc72fd' -H 'Content-Type: application/json' -d "{\"msgtype\": \"text\", \"text\": {\"content\":  \" 野豹$node 监控l2tpns程序掉线\"}}"
fi

}

tcpproxy(){
	pgrep httpproxy>/dev/null 2>&1 || curl 'https://oapi.dingtalk.com/robot/send?access_token=89a01c02f1d866f66d86415ee47e8895c626f512e3928a83daa99685babc72fd' -H 'Content-Type: application/json' -d "{\"msgtype\": \"text\", \"text\": {\"content\":  \" 野豹$node 监控httpproxy程序掉线\"}}"
}

#vppp_ikev2
dpkg -l ysnet-socks5 >/dev/null 2>&1 && {
	vppp_sock5
    socks5udp
    socks5
    socks5_plur
}

dpkg -l ysnet-proxy >/dev/null 2>&1 && tcpproxy

#l2tpns
