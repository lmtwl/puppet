class xunyou::ssh {
package {
    ["libpam-cracklib"]:
    ensure => installed;
}
user {
     "liuqin":
     ensure   => present,
     shell =>"/bin/bash",
     home  => "/home/liuqin",
     managehome => true,
     comment =>"web admin guanli",
     groups =>["www-data","adm","sudo"],
     password => '$6$MqR4Z/PT$klHrS5Y5w4OIpoTXGWc4lcG8dHvhPtnLeNEDKu9Qgeww1CjgnAS9FRKdJ0DTEEOQQ3ovz8Jn0KJBvfatrD1KL0';
     "update":
     ensure   => present,
     shell =>"/bin/bash",
     home  => "/home/update",
     managehome => true,
     comment =>"web update",
     groups =>["www-data"],
     password => '$6$s5Rgp7oh$OUaMNs7vlKCeTpvwTQa7Q1nFU0.zjXx5SULg6GaWC5goaDuMOevyN8.xxEp4tTR9oZdt3D/JeZlUH4nDhhgbg.';
     "ubuntu":
     ensure   => absent;
     "syslog":
     ensure   => present,
     groups =>["www-data","adm"];
     "audit":
     ensure   => present,
     shell =>"/bin/bash",
     home  => "/home/audit",
     managehome => true,
     comment =>"log audit",
     groups =>["adm"],
     password => '$6$s5Rgp7oh$OUaMNs7vlKCeTpvwTQa7Q1nFU0.zjXx5SULg6GaWC5goaDuMOevyN8.xxEp4tTR9oZdt3D/JeZlUH4nDhhgbg.';
     
       }

file {
        "/etc/hosts.allow":
        mode => "0644",
        source => "puppet:///modules/${module_name}/ssh/hosts.allow";
        "/etc/hosts.deny":
        mode => "0644",
        source => "puppet:///modules/${module_name}/ssh/hosts.deny";
	"/etc/sudoers.d/webadmin":
        mode => "0644",
	source => "puppet:///modules/${module_name}/ssh/webadmin";
	"/etc/pam.d/common-auth":
	mode => "0644",
	source => "puppet:///modules/${module_name}/ssh/common-auth";
	

}

ssh_authorized_key {
                        "root@xunyou.com":
                        user => root,
                        type => "ssh-rsa",
                        key => "AAAAB3NzaC1yc2EAAAABIwAAAQEAu83Sa+I3XVGY7FMesg8rZeI/AFgB7vGvtF5R4wEogI1E/LKBKlJaV4sqxjLWFvKFbxZhb4G6JI/g6CPMOqJVyWM51GyCI3ENnmoLeNoV1jaOHU6aFrBbUK+Ynp+kdAVjxJ1QCoMpBcU75mQ1qCJW+Lhy/Z2crvivMXVSYg93kZ+985MSE37zlLZ2KkveieFebG2pTulEOlQZPHM+XFb/+6TRLn7DVNvsQzba6owaltEBhPpfCTSV+kSIrxeC24qsYRW+cwUzE79dck9ZBi8IV99N5hBlS2V0678ARsmOFXan6zGCrCUg23xrJig3SlGqY2QZUoH4pgXrbtEEGlCe6Q==";
                        "liuqin@xunyou.com":
                        user => 'liuqin',
                        type => "ssh-rsa",
                        target => '/home/liuqin/.ssh/authorized_keys',
                        key => "AAAAB3NzaC1yc2EAAAABIwAAAQEA1Y2gowQmBlykS0OzccXoUlJcjWpViOxcAogdMG5P4r+2V7PB4qkdYnYXuUjWPz7cysBmXuHJg2JQYqVnag72EbZWVK20B28LiZS4PfD/A91L5cXIRauE9nTakHBaSOT4mTt+bhvpybsrOeCE/C2cpg2HnYXlqAwHLl+65M/TWAVHYFFTFpVWeJuYzdYvD2qFrzSq0RnS3IFDFRM4W2339wYnA90XbWd03TrKCp0QDdjjii8ilklE0opXCo6Mnk7hsUYKDfQAYzG+Nodl6Ttm6Jco7duQU6Ut/BBtEY03FOsrHsguFQ6Y2Jy/OFqJBNFicTXHzjNW47UrHY+GlhZaGQ==";

                        "update@xunyou.com":
                        user => 'update',
                        type => "ssh-rsa",
                        target => '/home/update/.ssh/authorized_keys',
                        key => "AAAAB3NzaC1yc2EAAAABIwAAAQEAvXVhX+wlRmuynD5q2UOc4fKpqPhkIl5VK5LZGancBvqincLRpHzZ2L0Akh4vN85lzTaBxldWZ+WvuRoTZNxIOnmXUt+O7FePPjwdIZLrOI9gH/CI6g39RmrWzLGlioUvCZBBnmY4purvpE3RR5j22VvisRr7kZ36hvQh5kM1gHP4j232x5WrRLyePiXHT4F5ycM/iedyS2F8ioaVL9VuUE78RQYA9uiwf9K9EBl6l/be2ZqXMcNw1Do2qPTvKPXcdv4mBT39zW/+oiVkw/bdjfJUv8aEKbw369StzZehanY7L3FCp4Xl8xlvK9tFAa5adIiilQ4UJgI7KalSxtUwWQ==";

                }

augeas { "set sshd_config":
	context => "/files/etc/ssh/sshd_config",
        changes => [
                "set PermitRootLogin without-password",
                "set Port 32333",
                "set X11Forwarding no",
		"set PasswordAuthentication no",
        ];
	"set login_defs":
	context => "/files/etc/login.defs",
	changes => [
		"set PASS_MAX_DAYS 90",
		"set PASS_MIN_DAYS 2",
        "set PASS_MAX_LEN 20",
        "set PASS_WARN_AGE 14",
	];
}


service {
	"ssh":
       subscribe => Augeas["set sshd_config"],
       ensure => running;
}
}

