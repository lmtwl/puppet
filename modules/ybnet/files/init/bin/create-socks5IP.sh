#!/bin/bash
# By : Wang
# History : 2021-09-16
# Description : 根据唯一id生成socksIP;
# set -x
#
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

[[ -f "/etc/nodeinfo.ini" ]] || bash /opt/ysnet/init/bin/create-code-info.sh
ID=$(grep "id:" "/etc/nodeinfo.ini" | awk -F ":" '{print $2}')
FILE_MAKE="/opt/ysnet/init/bin/makeip.sh"
NETWORK_FILE="/etc/netplan/99-socks5.yaml"

[[ -n "${ID}" ]] || {
    echo "Please Check File /etc/nodeinfo.ini "
    exit 0
}
[[ -n "$(echo "${ID}" | sed -n "/^[0-9]\+$/p")" ]] || {
    echo "PK Number Must Be Int."
    exit 0
}
[[ -f "${FILE_MAKE}" ]] && ARR=$(bash "${FILE_MAKE}" "${ID}")
[[ -n "${ARR}" ]] || exit 0

function InitializeNetplan() {
    cat >"${NETWORK_FILE}" <<EOF
network:
  version: 2
  renderer: networkd
  bridges:
    socks5:
      dhcp4: no
      addresses: 
EOF
}

function cdr2mask() {
  set -- $(( 5 - ($1 / 8) )) 255 255 255 255 $(( (255 << (8 - ($1 % 8))) & 255 )) 0 0 0
  if [[ "$1" -gt 1 ]] ;then
    shift "$1"
  else
    shift
  fi
  echo "${1-0}"."${2-0}"."${3-0}"."${4-0}"
}

function get_addr() {
  op='&'
  unset net
  while [ "$5" ]; do
    num=$(( $1 $op $5 ))
    shift
    net="${net}.${num}"
    sleep 0.01
  done
  }

function exportIP(){
  ip="${ARR}"
  address=${ip%/*}
  mlen=${ip#*/}
  mask=$(cdr2mask "${mlen}")
  ip="$address $mask"
  all=(${ip//[!0-9]/ })
  get_addr ${all[@]}
  all=(${net//./ })
  n=$((2**(32-mlen)))
  n1="${all[0]}"
  n2="${all[1]}"
  n3="${all[2]}"
  n4="${all[3]}"
  for((i=0;i<n;i++))
  do
    if [[ "${n4}" -eq 256 ]] ;then
      n4=0
      ((n3++))
      if [[ "${n3}" -eq 256 ]] ;then
        n3=0
        ((n2++))
        if [[ "${n2}" -eq 256 ]] ;then
          n2=0
          ((n1++))
        fi
      fi
    fi
    if [[ "${i}" -gt 0 ]] && [[ $i -le $((n-2)) ]] ;then
        echo "      - ${n1}.${n2}.${n3}.${n4}/${mlen}" >> "${NETWORK_FILE}"
    fi
    ((n4++))
    sleep 0.01
  done
}
InitializeNetplan
exportIP
