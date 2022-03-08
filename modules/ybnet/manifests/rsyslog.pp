class ybnet::rsyslog{
  file { '/etc/logrotate.d/rsyslog':
    notify => Service["rsyslog"],
    source =>"puppet:///modules/${module_name}/rsyslog/rsyslog";
    '/etc/rsyslog.d/ysnet-log.conf':
      notify => Service["rsyslog"],
      source =>"puppet:///modules/${module_name}/rsyslog/ysnet-log.conf";
  }
  service { 'rsyslog':
    ensure =>true,
    subscribe => File["/etc/logrotate.d/rsyslog","/etc/rsyslog.d/ysnet-log.conf"],
    hasrestart => true;
  }
}