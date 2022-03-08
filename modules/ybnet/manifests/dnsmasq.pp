class ybnet::dnsmasq{
  if $dnsmasq_installed == "0" {
    file {
     '/etc/default/dnsmasq':
        notify => Service["dnsmasq"],
        source => "puppet:///modules/${module_name}/dnsmasq/dnsmasq";
     '/etc/dnsmasq.conf':
        notify => Service["dnsmasq"],
        source => "puppet:///modules/${module_name}/dnsmasq/dnsmasq.conf";
      '/etc/dnsmasq.d/':
        source =>"puppet:///modules/${module_name}/dnsmasq/dnsmasq.d",
        mode => "0755",
        ensure => directory,
        recurse =>true,
        purge => true,
        force => true,
        notify => Service["dnsmasq"];
     '/etc/init.d/dnsmasq':
        mode => "0755",
        notify => Service["dnsmasq"],
        source => "puppet:///modules/${module_name}/dnsmasq/dnsmasqinit";
    }
    service { 'dnsmasq':
      ensure => true,
      hasrestart => true;
    }
  }
}
