class ybnet::monitor{
  cron { 'monitor-code':
    command => 'bash /usr/local/bin/monitor/src/cron.d/monitor_cron.sh >/dev/null 2>&1',
    user => 'root',
    ensure => present,
    minute  => '*/10';
  }
  file { '/usr/local/bin/monitor/':
    source => "puppet:///modules/${module_name}/monitor/monitor/",
    mode => "0755",
    ensure => directory,
    recurse => true,
    purge => true,
    force => true;
  }
}