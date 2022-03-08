class ysnet::network ( ) {
  package { ["netplan.io"]:
    ensure => installed,
  }
  file {
    '/etc/netplan/55-bridges.yaml':
       source => ["puppet:///modules/${module_name}/network/55-bridges.yaml"];
  }
}

