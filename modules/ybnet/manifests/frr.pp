class ybnet::frr {
  if $node == "3" {
    package { 'frr':
      ensure => latest;
    }
    file {
      '/etc/frr/daemons':
        notify => Service["frr"],
        source=>"puppet:///modules/${module_name}/frr/daemons";
      '/etc/frr/frr.conf':
        notify => Service["frr"],
        content=>template("${module_name}/frr.conf.erb");
    }
    service { 'frr':
      ensure =>true,
      subscribe => File["/etc/frr/frr.conf"],
      hasrestart => true;
    }
  }
}
