#!/bin/bash

# 网站服务器上定时执行

PULL_PATH="/usr/share/nginx"
PUBLISH_PATH="/etc/webbranch"

# 判断分支，并定义rsync模块名
function getmode(){
  if [[ -s "${PUBLISH_PATH}" ]] ;then
    PUBLISH_BRANCH=$(cat "${PUBLISH_PATH}")
  else
    PUBLISH_BRANCH="master"
  fi
}

function checkmode(){
  if [[ "${PUBLISH_BRANCH}" != "master" && "${PUBLISH_BRANCH}"  != "test" && "${PUBLISH_BRANCH}"  != "prerelease" ]] ;then
    exit 0
  fi
}

function pullcode(){
  rsync -avz --delete --password-file=/etc/rsync.passwd web@123.56.97.110::"${PUBLISH_BRANCH}" "${PULL_PATH}"
}

function main(){
  getmode
  checkmode
  pullcode
}

main
