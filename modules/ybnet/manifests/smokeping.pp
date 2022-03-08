class ybnet::smokeping(String $smkdata = "/opt/ysnet/init/git/puppet/modules/ybnet/files/smokeping/address") {
  if $smokeping_installed == "0" {
    include ybnet::apache
    package {
      ["ttf-wqy-zenhei","smokeping"]:
        ensure => installed,
    }

    file { '/etc/smokeping/config':
      notify => Service["smokeping"],
      content => template("${module_name}/smokeping.config.erb");
    }
    file { '/etc/apache2/conf-enabled/smksec.conf':
      source => "puppet:///modules/${module_name}/smokeping/smokeping-sec";
    }
    file { '/etc/apache2/htpasswd.users':
      source => "puppet:///modules/${module_name}/smokeping/smokeping-user";
    }
    file { '/etc/apache2/conf-enabled/smokeping.conf':
      source => "puppet:///modules/${module_name}/smokeping/smokeping.conf";
    }
    #file { '/etc/apache2/conf-enabled/smk.conf':
    #  ensure => link,
    #  target => '/etc/smokeping/apache2.conf';
    #}
    file { '/etc/smokeping/version':
      source => "puppet:///modules/${module_name}/smokeping/ver";
    }
    file { '/etc/smokeping/address':
      notify => Service["smokeping"],
      source =>"puppet:///modules/${module_name}/smokeping/address",
      mode => "0644",
      ensure => directory,
      recurse =>true,
      purge => true,
      force => true;
    }
    exec {
      "touch local eth0 conf":
        refreshonly => false,
        creates => "/etc/smokeping/local.eth0",
        command => "/bin/touch /etc/smokeping/local.eth0";

      "touch local eth1 conf":
        refreshonly => false,
        creates => "/etc/smokeping/local.eth1",
        command => "/bin/touch /etc/smokeping/local.eth1";

      "touch local eth2 conf":
        refreshonly => false,
        creates => "/etc/smokeping/local.eth2",
        command => "/bin/touch /etc/smokeping/local.eth2";

      "touch local eth3 conf":
        refreshonly => false,
        creates => "/etc/smokeping/local.eth3",
        command => "/bin/touch /etc/smokeping/local.eth3";

      "touch local dr conf":
        refreshonly => false,
        creates => "/etc/smokeping/local.dr",
        command => "/bin/touch /etc/smokeping/local.dr";

      "cgid.conf":
        path => "/usr/bin:/bin:/usr/sbin:/sbin",
        refreshonly => false,
        creates => "/etc/apache2/mods-enabled/cgid.load",
        command => "ln -s /etc/apache2/mods-available/cgid.load /etc/apache2/mods-enabled/cgid.load";

      "cgi.conf":
        path => "/usr/bin:/bin:/usr/sbin:/sbin",
        refreshonly => false,
        creates => "/etc/apache2/mods-enabled/cgi.load",
        command => "ln -s /etc/apache2/mods-available/cgid.load /etc/apache2/mods-enabled/cgi.load";
    }
    service {
      "smokeping":
        ensure => true,
        subscribe => File["/etc/smokeping/address"],
        hasrestart => true;
      "apache2":
        ensure => true,
        subscribe => File["/etc/apache2/htpasswd.users"],
        hasrestart => true;
    }
  }
}
