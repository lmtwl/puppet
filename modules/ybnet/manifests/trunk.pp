class ybnet::trunk {
  Exec {
    path => "/usr/bin:/bin:/usr/sbin:/sbin",
    refreshonly => false,
    logoutput => false
  }
  if $node == "2" {
    # 通用规则
    if $socks5_installed == "0"{
      # 接入
      exec { 'masquerade-rule':
        unless => 'iptables -t nat -C POSTROUTING -o trunk -j MASQUERADE',
        command => 'iptables -t nat -A POSTROUTING -o trunk -j MASQUERADE';

        'in-prerouting-53':
          unless => 'iptables -t nat -C PREROUTING -d 8.8.8.1/32 -p udp -m udp --dport 53 -j DNAT --to-destination 8.8.8.8:53',
          command => 'iptables -t nat -A PREROUTING -d 8.8.8.1/32 -p udp -m udp --dport 53 -j DNAT --to-destination 8.8.8.8:53';

        'in-output-53':
          unless => 'iptables -t nat -C OUTPUT -d 8.8.8.1/32 -p udp -m udp --dport 53 -j DNAT --to-destination 8.8.8.8:53',
          command => 'iptables -t nat -A OUTPUT -d 8.8.8.1/32 -p udp -m udp --dport 53 -j DNAT --to-destination 8.8.8.8:53';
      }
    }
    else{
      # 出口
      exec { 'add-trunk':
          unless => 'iptables -t nat -C POSTROUTING -s 192.168.254.0/30 ! -d 192.168.254.0/30 -j MASQUERADE',
          command => 'iptables -t nat -A POSTROUTING -s 192.168.254.0/30 ! -d 192.168.254.0/30 -j MASQUERADE';
      }
    }
  }
  if $node == "4" {
    # 通用规则
    exec {'del-nat':
      onlyif => 'iptables -t nat -C POSTROUTING -o nat -j MASQUERADE',
      command => 'iptables -t nat -D POSTROUTING -o nat -j MASQUERADE';
      
      'masquerade-rule':
        unless => 'iptables -t nat -C POSTROUTING -s 192.168.254.0/30 ! -d 192.168.254.0/30 -j MASQUERADE',
        command => 'iptables -t nat -A POSTROUTING -s 192.168.254.0/30 ! -d 192.168.254.0/30 -j MASQUERADE';

      'out-prerouting-53':
          unless => 'iptables -t nat -C PREROUTING -d 8.8.8.1/32 -p udp -m udp --dport 53 -j DNAT --to-destination 8.8.8.8:53',
          command => 'iptables -t nat -A PREROUTING -d 8.8.8.1/32 -p udp -m udp --dport 53 -j DNAT --to-destination 8.8.8.8:53';

      'out-output-53':
          unless => 'iptables -t nat -C OUTPUT -d 8.8.8.1/32 -p udp -m udp --dport 53 -j DNAT --to-destination 8.8.8.8:53',
          command => 'iptables -t nat -A OUTPUT -d 8.8.8.1/32 -p udp -m udp --dport 53 -j DNAT --to-destination 8.8.8.8:53';
    }
    if $socks5_installed != "0" {
      # 接入
      exec { 'add-rule':
        # 后续优化
        command => 'bash /opt/ysnet/init/git/puppet/modules/ybnet/files/trunk/add-iptables.sh';
      }
    }
  }
  if $node == "5" {
    # 通用规则
    if $socks5_installed == "0"{
      # 接入
      exec { 'masquerade-rule':
        unless => 'iptables -t nat -C POSTROUTING -o trunk -j MASQUERADE',
        command => 'iptables -t nat -A POSTROUTING -o trunk -j MASQUERADE';

        'in-prerouting-53':
          unless => 'iptables -t nat -C PREROUTING -d 8.8.8.1/32 -p udp -m udp --dport 53 -j DNAT --to-destination 8.8.8.8:53',
          command => 'iptables -t nat -A PREROUTING -d 8.8.8.1/32 -p udp -m udp --dport 53 -j DNAT --to-destination 8.8.8.8:53';

        'in-output-53':
          unless => 'iptables -t nat -C OUTPUT -d 8.8.8.1/32 -p udp -m udp --dport 53 -j DNAT --to-destination 8.8.8.8:53',
          command => 'iptables -t nat -A OUTPUT -d 8.8.8.1/32 -p udp -m udp --dport 53 -j DNAT --to-destination 8.8.8.8:53';
      }
    }
    else{
      # 出口
      exec { 'add-trunk':
          unless => 'iptables -t nat -C POSTROUTING -s 192.168.254.0/30 ! -d 192.168.254.0/30 -j MASQUERADE',
          command => 'iptables -t nat -A POSTROUTING -s 192.168.254.0/30 ! -d 192.168.254.0/30 -j MASQUERADE';
      }
    }
  }
}
