# 2020.8.5
Exec {
  path => ["/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",],
  refreshonly => true,
}
File {
  ensure => present,
  mode => '0644',
  owner => 'root',
  group => 'root',
}
