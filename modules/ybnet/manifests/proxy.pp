class ybnet::proxy{
  if $proxy_installed == "10" {
    if $node == "3" {
      file {
        '/opt/ysnet/proxy/etc':
          source =>"puppet:///modules/${module_name}/proxy/etc",
          mode => "0755",
          ensure => directory,
          recurse =>true,
          purge => true,
          force => true;
      }
    }elsif $node == "5" {
      file {
        '/opt/ysnet/proxy/etc':
          source =>"puppet:///modules/${module_name}/proxy/cn_etc",
          mode => "0755",
          ensure => directory,
          recurse =>true,
          purge => true,
          force => true;
      }
    }elsif $node == "4" {
      file {
        '/opt/ysnet/proxy/etc':
          source =>"puppet:///modules/${module_name}/proxy/independ_etc",
          mode => "0755",
          ensure => directory,
          recurse =>true,
          purge => true,
          force => true;
      }
    }else{
      file {
        '/opt/ysnet/proxy/etc':
          source =>"puppet:///modules/${module_name}/proxy/trunk_etc",
          mode => "0755",
          ensure => directory,
          recurse =>true,
          purge => true,
          force => true;
      }
    }
    exec { 'proxy':
      path => "/usr/bin:/bin:/usr/sbin:/sbin",
      refreshonly => false,
      unless => 'pgrep httpproxy > /dev/null 2>&1',
      command => "service ysnet-proxy start > /dev/null 2>&1";
    }
    if $proxy_status == "0" {
      firewall {
        '200 outproxy':
           ensure    => present,
           chain     => 'OUTPUT',
           table     => 'nat',
           proto     => 'tcp',
           dport     => [80, 443],
           match_mark => "0x0",
           jump      => 'DNAT',
           todest    => '172.31.255.254:88';
        '200 preproxy':
           ensure    => present,
           chain     => 'PREROUTING',
           table     => 'nat',
           proto     => 'tcp',
           dport     => [80, 443],
           match_mark => "0x0",
           jump      => 'DNAT',
           todest    => '172.31.255.254:88';
      }
    }
  }
}
