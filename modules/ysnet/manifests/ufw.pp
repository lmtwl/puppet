class ysnet::ufw {
  firewall {
    '200 TCPMSS':
      chain     => 'FORWARD',
      table     => 'mangle',
      proto     => 'tcp',
      tcp_flags => 'SYN,RST SYN',
      clamp_mss_to_pmtu  =>'true',
      jump      => 'TCPMSS';
  }
}
