#!/bin/bash
# By : Wang
# History : 2020-10-09
# Discription : new natopen rules for ubuntu20.04 .
# set -x
#
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
export PRESENT_PID=$$

NATOPEN_FILE="/opt/ysnet/init/bin/natopen"

trap 'exit 1' TERM

function ExitShell(){
    kill -s TERM "${PRESENT_PID}"
}

function WhetherContinue(){
    if [[ $1 == "n" ]]; then
        ExitShell
    fi
}

# install 
read -r -p 'install iptables-dev continue?[y/n]' arr
WhetherContinue "${arr}"
apt update
apt install libxtables-dev libip6tc-dev libip4tc-dev

# make
read -r -p 'compile modules continue?[y/n]' arr
WhetherContinue "${arr}"
make

# modprobe
read -r -p 'install modules continue?[y/n]' arr
WhetherContinue "${arr}"
cp xt_FULLCONENAT.ko /lib/modules/$(uname -r)/kernel/net/ipv4/netfilter/
# -r暂时不去掉，递归的场景未知
grep -q -r xt_FULLCONENAT /etc/modules  || echo xt_FULLCONENAT >> /etc/modules
depmod
modprobe xt_FULLCONENAT
# ubutnu14.04目录/lib/xtables/，20.04为/usr/lib/x86_64-linux-gnu/xtables
cp libipt_FULLCONENAT.so /usr/lib/x86_64-linux-gnu/xtables

# sed -i '/natmodule/d' /etc/rc.local
# rmmod natmodule

read -r -p 'config iptables continue?[y/n]' arr
WhetherContinue "${arr}"

[[ -f "${NATOPEN_FILE}" ]] && chattr -i "${NATOPEN_FILE}"
cat > "${NATOPEN_FILE}" << EOF
#!/bin/bash
default_gw=$(ip route | grep default | awk -F " " '{print $5}')
iptables -t nat -C PREROUTING -i "\${default_gw}" -p udp -j FULLCONENAT >/dev/null 2>&1 || iptables -t nat -I PREROUTING -i "\${default_gw}" -p udp -j FULLCONENAT >/dev/null 2>&1
iptables -t nat -C POSTROUTING -o "\${default_gw}" -p udp -j FULLCONENAT >/dev/null 2>&1 || iptables -t nat -I POSTROUTING -o "\${default_gw}" -p udp -j FULLCONENAT >/dev/null 2>&1
EOF

echo "* * * * * root bash /opt/ysnet/init/bin/natopen >/dev/null 2>&1" > /etc/cron.d/natopen
chmod +x "${NATOPEN_FILE}"
chattr +i "${NATOPEN_FILE}"
bash "${NATOPEN_FILE}"
iptables -t nat -L -nv |grep FULL
