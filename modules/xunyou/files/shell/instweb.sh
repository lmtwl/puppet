#!/bin/bash
#sleep ${1:-$(($RANDOM%60))}
export RSYNC_PASSWORD=securityGroupTips

basedir=${2:-"/opt/xunyou/init"}
repo_data="puppet-data"
repo_code="puppet-code"
wd="${basedir}/git"
gitloc="${basedir}/var/"

[ -d $wd ]||mkdir -p $wd

rsync -avz --delete admin@106.15.195.140::web/ $wd/


[ -d ${wd}/${repo_code}/manifests ]&&puppet apply --config ${wd}/${repo_code}/etc/puppet.conf --modulepath=${wd}/${repo_code}/modules ${wd}/${repo_code}/manifests/site.pp
