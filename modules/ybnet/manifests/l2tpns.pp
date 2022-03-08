class ybnet::l2tpns{
  if $install_l2tpns == "0"{
    exec {
      "l2tp-masq":
        path => "/usr/bin:/bin:/usr/sbin:/sbin",
        refreshonly => false,
        logoutput => false,
        unless => 'iptables -t nat -C POSTROUTING -s 172.16.0.0/16 ! -d 172.16.0.0/16 -j MASQUERADE',
        command => 'iptables -t nat -A POSTROUTING -s 172.16.0.0/16 ! -d 172.16.0.0/16 -j MASQUERADE';
      }
  }
}
