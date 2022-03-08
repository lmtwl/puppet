class ybnet::ufw {
  firewall {
    '200 TCPMSS':
      chain     => 'FORWARD',
      table     => 'mangle',
      proto     => 'tcp',
      tcp_flags => 'SYN,RST SYN',
      clamp_mss_to_pmtu  =>'true',
      jump      => 'TCPMSS';
    '100 pubg-voice':
      chain     => 'OUTPUT',
      table     => 'nat',
      destination => '74.201.106.170',
      action      => 'accept';
    '100 tkf1':
      chain     => 'OUTPUT',
      table     => 'nat',
      destination => '104.22.28.180',
      action      => 'accept';
    '100 tkf2':
      chain     => 'OUTPUT',
      table     => 'nat',
      destination => '104.22.29.180',
      action      => 'accept';
    '100 tkf3':
      chain     => 'OUTPUT',
      table     => 'nat',
      destination => '172.67.41.203',
      action      => 'accept';
    '110 post masq':
      chain     => 'POSTROUTING',
      table     => 'nat',
      proto     => 'all',
      match_mark => "0x1e",
      jump => 'MASQUERADE';
    '100 udp 80443 drop':
      chain     => 'OUTPUT',
      table     => 'mangle',
      proto     => 'udp',
      dport     => '443',
      action      => 'drop';
  }
}
