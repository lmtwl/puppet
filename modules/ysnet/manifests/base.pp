#class ysnet::base ( String $timeserver = '59.151.39.244' ) {
class ysnet::base ( ) {
  service  {
     'systemd-resolved':
       name => "systemd-resolved.service",
       provider => "systemd",
       ensure => stopped,
       stop=>true;
  }
 
  exec {
    'apt-key':
      path => "/usr/bin:/bin:/usr/sbin:/sbin",
      refreshonly => false,
      onlyif => 'test -f /etc/apt/trusted.gpg.d/ubuntu-keyring-2018-archive.gpg',
      command => 'apt-key add /opt/ysnet/puppet/modules/ysnet/files/base/keys.asc';
  }

  file {
    '/etc/timezone':
    content => "Asia/Shanghai\n";
    '/etc/localtime':
    ensure => link,
    target => '/usr/share/zoneinfo/Asia/Shanghai';
    '/root/.vimrc':
      content => "set background=dark\n";
    '/etc/resolv.conf':
      ensure => file,
      content => "nameserver 8.8.8.8\n";

    '/etc/apt/sources.list':
       source => ["puppet:///modules/${module_name}/base/sources.list"];

    '/etc/sysctl.conf':
       source => "puppet:///modules/${module_name}/base/sysctl.conf";
  }
 exec {
   "update sorcelist":
    path => "/usr/bin:/bin:/usr/sbin:/sbin",
    subscribe => File["/etc/apt/sources.list"],
    command => "apt update";

    "update timezone":
      path => "/usr/bin:/bin:/usr/sbin:/sbin",
      subscribe => File["/etc/localtime"],
      command => "dpkg-reconfigure --frontend noninteractive tzdata";
  }
  package { ["net-tools","nload","fping","augeas-tools","vnstat","ruby","htop","mtr","ntpdate","gnupg","screen","curl","tzdata","traceroute","ethtool","sysstat","iptables-persistent","ca-certificates","bridge-utils","iftop"]:
    ensure => installed,
  }
}
