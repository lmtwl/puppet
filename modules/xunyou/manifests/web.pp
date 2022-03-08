class xunyou::web{
	package {
		["php5","php5-cgi","php5-cli","php5-common","php5-curl","php5-fpm","php5-gd","php5-imap","php5-mcrypt","php5-mysql","php5-redis","nginx-full","auditd"]:
		ensure => installed;
	}
	
	file {
		"/etc/php5/fpm/php.ini":
		notify => Service["php5-fpm"],
		source => "puppet:///modules/${module_name}/php5fpm/php.ini";
		"/etc/php5/fpm/php-fpm.conf":
		notify => Service["php5-fpm"],
		source => "puppet:///modules/${module_name}/php5fpm/php-fpm.conf";
		"/etc/php5/fpm/pool.d/www.conf":
		notify => Service["php5-fpm"],
		source => "puppet:///modules/${module_name}/php5fpm/www.conf";
		"/etc/logrotate.d/php5fpm":
		source => "puppet:///modules/${module_name}/logrotate/php5fpm";
		"/etc/init.d/php5-fpm":
		mode => 0755,
		source => "puppet:///modules/${module_name}/init.d/php5-fpm";

		"/etc/nginx/nginx.conf":
		notify => Service["nginx"],
		source => "puppet:///modules/${module_name}/nginx/nginx.conf";
        "/etc/nginx/limit_zone.conf":
        notify => Service["nginx"],
        source => "puppet:///modules/${module_name}/nginx/limit_zone.conf";
        "/etc/nginx/whiteip.conf":
        notify => Service["nginx"],
        source => "puppet:///modules/${module_name}/nginx/whiteip.conf";

		"/etc/logrotate.d/nginx":
		source => "puppet:///modules/${module_name}/logrotate/nginx";

                "/etc/nginx/ssl":
                notify => Service["nginx"],
                source =>"puppet:///modules/${module_name}/nginx/ssl",
                ensure => directory,
                recurse =>true,
                purge =>true,
                force =>true;

		"/etc/nginx/fastcgi_params":
                mode => 0644,
                source => "puppet:///modules/${module_name}/nginx/fastcgi_params";

		"/usr/local/bin/addx.sh":
                mode => 0755,
                source => "puppet:///modules/${module_name}/shell/addx.sh";

#                "/usr/local/bin/sync-log.sh":
#                mode => 0755,
#                source => "puppet:///modules/${module_name}/shell/sync-log.sh";
#
#                "/etc/cron.d/sync-log":
#                content => "5 3 * * * root /usr/local/bin/sync-log.sh\n";

                "/usr/local/bin/instweb.sh":
                mode => 0755,
                source => "puppet:///modules/${module_name}/shell/instweb.sh";
                "/usr/local/bin/pullcode_uni.sh":
                mode => 0755,
                source => "puppet:///modules/${module_name}/shell/pullcode_uni.sh";
		"/usr/local/bin/logwc.sh":
                mode => 0755,
                source => "puppet:///modules/${module_name}/shell/logwc.sh";
		"/etc/nginx/sites-enabled":
		notify => Service["nginx"],
		source =>"puppet:///modules/${module_name}/nginx/vhost",
		ensure => directory,		
		recurse =>true,
		purge =>true,
		force =>true;





	}
	service {
        	"php5-fpm":
	    	hasrestart => true,
            ensure => running;
	        "nginx":
        	hasrestart => true,
            ensure => running;
		
	}

	
}
