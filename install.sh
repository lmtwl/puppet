#!/bin/bash
sleep ${1:-$(($RANDOM%60))}
basedir=${2:-"/opt/ybnet"}
repo_code="puppet"
#wd="${basedir}/git"
wd="${basedir}"
gitloc="${basedir}/var/"
stable=true
puppet apply --config ${wd}/${repo_code}/etc/puppet.conf --modulepath=${wd}/${repo_code}/modules ${wd}/${repo_code}/manifests/site.pp
