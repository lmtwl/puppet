#!/bin/bash
# todo:
# yaml 语法检查
# 认证
fn="/opt/xunyou/init/git/puppet-data/perhost/${1}/puppet.yaml"
lf="/etc/puppet.yaml"
dft="/opt/xunyou/init/git/puppet-code/etc/puppet.yaml"

if [ -f $lf ];then 
	cat $lf
	exit 0
fi

if [ -f $fn ];then
	cat $fn
else
	cat $dft
fi
exit 0
