class xunyou::nginx{
        package {
                "nginx-full":
                ensure => installed;
        }

        file {
        "/etc/nginx/nginx.conf":
        notify => Service["nginx"],
        source => "puppet:///modules/${module_name}/nginx/nginx.conf";
        "/etc/nginx/sites-enabled/xunyou.conf":
        notify => Service["nginx"],
        source => "puppet:///modules/${module_name}/nginx/xunyou.conf";
        "/etc/logrotate.d/nginx":
        source => "puppet:///modules/${module_name}/logrotate/nginx";

        "/etc/nginx/ssl/xunyou.crt":
        mode => 0644,
        source => "puppet:///modules/${module_name}/nginx/xunyou.crt";
        "/etc/nginx/ssl/xunyou.key":
        mode => 0644,
        source => "puppet:///modules/${module_name}/nginx/xunyou.key";

        "/etc/nginx/fastcgi_params":
        mode => 0644,
        source => "puppet:///modules/${module_name}/nginx/fastcgi_params";


        }
service {
        "nginx":
        #ensure => running;
	hasrestart => true;
        }

}
