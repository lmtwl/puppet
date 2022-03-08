class xunyou::fail2ban{
	package {
		["fail2ban","ipset"]:
		ensure => installed;
	}
	
	file {
		"/etc/fail2ban/jail.conf":
        notify => Service["fail2ban"],
		source => "puppet:///modules/${module_name}/fail2ban/jail.conf";
		"/etc/fail2ban/action.d/ipset.conf":
		source => "puppet:///modules/${module_name}/fail2ban/action.ipset.conf";
		"/etc/fail2ban/action.d/iptables-cdn.conf":
		source => "puppet:///modules/${module_name}/fail2ban/action.iptables-cdn.conf";
		"/etc/fail2ban/filter.d/xunyou.conf":
		source => "puppet:///modules/${module_name}/fail2ban/filter.xunyou.conf";
		"/etc/fail2ban/filter.d/nginx-req-limit.conf":
		source => "puppet:///modules/${module_name}/fail2ban/filter.nginx-req-limit.conf";


		"/etc/fail2ban/filter.d/xycdn.conf":
		source => "puppet:///modules/${module_name}/fail2ban/filter.xycdn.conf";



	#	"/usr/local/bin/update-blackip.sh":
	#	mode => 0755,
	#	source => "puppet:///modules/${module_name}/fail2ban/shell/update-blackip.sh";
	#	"/usr/local/bin/update-blackip.php":
	#	source => "puppet:///modules/${module_name}/fail2ban/shell/update-blackip.php";
	#	"/usr/local/etc/serviceforweb20001.xml":
	#	source => "puppet:///modules/${module_name}/fail2ban/shell/serviceforweb20001.xml";
	#	"/etc/cron.d/xy-blackip":
	#	content => "* * * * * root /usr/local/bin/update-blackip.sh\n";
	}
    service {
            "fail2ban":
            hasrestart => true,
            ensure => running;

    }
	
}
