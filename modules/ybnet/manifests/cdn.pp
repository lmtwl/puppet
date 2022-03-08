class ybnet::cdn {
    if $proxy_installed == "10" {
      package { 'ysnet-cache':
        ensure => installed;
      }
      file { '/opt/ysnet/cache/nginx/conf/nginx.conf':
        notify => Service["ysnet-cache"],
        source => "puppet:///modules/${module_name}/nginx/nginx.conf";

        '/opt/ysnet/cache/nginx/conf/conf.d/':
          notify => Service["ysnet-cache"],
          source =>"puppet:///modules/${module_name}/nginx/conf.d",
          ensure => directory,
          recurse =>true,
          purge =>true,
          force =>true;
      
        '/opt/ysnet/cache/nginx/ssl/':
          notify => Service["ysnet-cache"],
          source =>"puppet:///modules/${module_name}/nginx/ssl",
          ensure => directory,
          recurse =>true,
          purge =>true,
          force =>true;
      }
      service { 'ysnet-cache':
        ensure =>true,
        hasrestart => true;
      }
    } 
}
