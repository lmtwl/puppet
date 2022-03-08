class ybnet::base ( ) {
  file { 
   '/etc/timezone':
      content => "Asia/Shanghai\n";
   '/etc/localtime':
      ensure => link,
      target => '/usr/share/zoneinfo/Asia/Shanghai';
    '/root/.vimrc':
      content => "set background=dark\n";
    '/etc/apt/sources.list':
      source => ["puppet:///modules/${module_name}/base/sources.list"];
    '/etc/apt/sources.list.d/frr.list':
      source => "puppet:///modules/${module_name}/frr/frr.list";
    '/etc/sysctl.conf':
      source => "puppet:///modules/${module_name}/base/sysctl.conf";
    '/etc/resolv.conf':
      ensure => file,
      content => "nameserver 127.0.0.53\n";
    '/etc/systemd/resolved.conf':
      ensure => file,
      source => "puppet:///modules/${module_name}/base/resolved.conf",
      notify => Service["systemd-resolved"];
    '/etc/puppetlabs/':
      ensure => directory,
      purge => true,
      recurse => true,
      force => true,
      source => "puppet:///modules/${module_name}/base/puppetlabs";
  }
  host { 'oapi.dingtalk.com':
    ip => "106.11.40.32",
    name => "oapi.dingtalk.com",
    ensure => present;

    'new-node.yebaojiasu.com':
    ip => "106.15.196.232",
    name => "new-node.yebaojiasu.com",
    ensure => present;

    'speed-ip.yebaojiasu.com':
    ip => "47.110.185.59",
    name => "speed-ip.yebaojiasu.com",
    ensure => present;

    'dbserver.akspeedy.com':
    ip => "139.196.172.164",
    name => "dbserver.akspeedy.com",
    ensure => present;

    'dbbak.akspeedy.com':
    ip => "139.196.172.164",
    name => "dbbak.akspeedy.com",
    ensure => present;

    'dbserver.yebaojiasu.com':
    ip => "106.15.3.165",
    name => "dbserver.yebaojiasu.com",
    ensure => present;

    'dbserver.jixianjiasu.com':
    ip => "106.15.3.165",
    name => "dbserver.jixianjiasu.com",
    ensure => present;

    'dbbak.jixianjiasu.com':
    ip => "106.15.3.165",
    name => "dbbak.jixianjiasu.com",
    ensure => present;

    'cesu.yebaojiasu.com':
    ip => "101.132.115.68",
    name => "cesu.yebaojiasu.com",
    ensure => present;

  }
  exec { 
    "update sorcelist":
      path => "/usr/bin:/bin:/usr/sbin:/sbin",
      subscribe => File["/etc/apt/sources.list"],
      command => "apt update";
    "update frr sorcelist":
      path => "/usr/bin:/bin:/usr/sbin:/sbin",
      subscribe => File["/etc/apt/sources.list.d/frr.list"],
      command => "apt update";
    "update timezone":
      path => "/usr/bin:/bin:/usr/sbin:/sbin",
      subscribe => File["/etc/timezone"],
      command => "dpkg-reconfigure --frontend noninteractive tzdata";
    "update timezonea":
      path => "/usr/bin:/bin:/usr/sbin:/sbin",
      subscribe => File["/etc/localtime"],
      command => "dpkg-reconfigure --frontend noninteractive tzdata";
    "update sysctl.conf":
      path => "/usr/bin:/bin:/usr/sbin:/sbin",
      subscribe => File["/etc/sysctl.conf"],
      command => "/usr/sbin/sysctl -p";
  }
  service { 'systemd-resolved':
      ensure => true,
      hasrestart => true;
  }
  package { ["net-tools","nload","fping","augeas-tools","vnstat","ruby","htop","mtr","ntpdate","gnupg","screen","curl","tzdata","traceroute","ethtool","sysstat","iptables-persistent","iftop","ca-certificates","python3-pip"]:
    ensure => installed;
    'bind9':
      ensure => purged;
  }
}
