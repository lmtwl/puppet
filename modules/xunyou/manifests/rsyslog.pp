class xunyou::rsyslog{
        file {
        "/etc/rsyslog.d/nginx.conf":
        notify => Service["rsyslog"],
        source => "puppet:///modules/${module_name}/rsyslog/nginx.conf";
        "/etc/nginx/sites-enabled/xunyou.conf":
        }
service {
        "rsyslog":
        #ensure => running;
        hasrestart => true;
        }

}
