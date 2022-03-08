class ybnet::init{
  file { '/opt/ysnet/init/bin':
    source =>"puppet:///modules/${module_name}/init/bin",
    mode => "0755",
    ensure => directory,
    recurse =>true,
    purge => true,
    force => true;
  }
  cron { 'liuliang.sh':
    command => '/opt/ysnet/init/bin/liuliang.sh >/dev/null 2>&1',
    user    => 'root',
    ensure => present,
    minute  => '*/5';
  }
}
