copy library
```
cp libipt_FULLCONENAT.so /lib/xtables/
```

Assuming eth0 is external interface:
```
iptables -t nat -A POSTROUTING -o eth0 -p udp -j FULLCONENAT #same as MASQUERADE  
iptables -t nat -A PREROUTING -i eth0 -p udp -j FULLCONENAT  #automatically restore NAT for inbound packets
```
Currently only UDP traffic is supported for full-cone NAT. For other protos FULLCONENAT is equivalent to MASQUERADE.

Assuming eth0 is external interface:

Basic Usage:

```
iptables -t nat -A POSTROUTING -o eth0 -p udp -j FULLCONENAT
iptables -t nat -A PREROUTING -i eth0 -p udp -j FULLCONENAT
```

Random port range:

```
#iptables -t nat -A POSTROUTING -o eth0 ! -p udp -j MASQUERADE
iptables -t nat -A POSTROUTING -o eth0 -p udp -j FULLCONENAT --to-ports 40000-60000 --random-fully

iptables -t nat -A PREROUTING -i eth0 -p udp -m multiport --dports 40000:60000 -j FULLCONENAT
```

Hairpin NAT (Assuming eth1 is LAN interface and IP range for LAN is 192.168.100.0/24):
```
iptables -t nat -A POSTROUTING -o eth0 -p udp -j FULLCONENAT
iptables -t nat -A POSTROUTING -o eth1 -s 192.168.100.0/24 -j MASQUERADE
iptables -t nat -A PREROUTING -i eth0 -p udp -j FULLCONENAT
iptables -t nat -A PREROUTING -i eth1 -p udp -j FULLCONENAT
```

:POSTROUTING
*nat
-j FULLCONENAT;=;OK
-j FULLCONENAT --random;=;OK
-j FULLCONENAT --random-fully;=;OK
-p tcp -j FULLCONENAT --to-ports 1024;=;OK
-p udp -j FULLCONENAT --to-ports 1024-65535;=;OK
-p udp -j FULLCONENAT --to-ports 1024-65536;;FAIL
-p udp -j FULLCONENAT --to-ports -1;;FAIL