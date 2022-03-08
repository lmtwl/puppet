class xunyou::php5fpm{
	package {
		["php5","php5-cgi","php5-cli","php5-common","php5-curl","php5-fpm","php5-gd","php5-imap","php5-mcrypt","php5-mysql","php5-snmp"]:
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

	}
	service {
        	"php5-fpm":
		#ensure => true,
      		#subscribe => File['/etc/php5/fpm/pool.d/www.conf'],
		hasrestart => true;
		
	}

	
}
