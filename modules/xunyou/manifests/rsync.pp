class xunyou::rsync{
	package {
		["rsync"]:
		ensure => installed;
	}
	
	file {
		"/etc/rsyncd.conf":
		notify => Service["rsync"],
        source => "puppet:///modules/${module_name}/rsync/rsyncd.conf";
        "/etc/rsyncd.secrets":
        mode => 0600,
        source => "puppet:///modules/${module_name}/rsync/rsyncd.secrets";

	}
    augeas { "set rsync":
        context => "/files/etc/default/rsync",
        changes => [
                "set RSYNC_ENABLE true",
        ];
}
	service {
        	"rsync":
        	hasrestart => true,
            ensure => running;
		
	}

	
}
