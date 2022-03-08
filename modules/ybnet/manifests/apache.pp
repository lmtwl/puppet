class ybnet::apache {
  package { ["apache2","libapache2-mod-fcgid"]:
    ensure  => installed,
  }
  exec { 'enable cgid':
    path => "/usr/bin:/bin:/usr/sbin:/sbin",
    creates => '/etc/apache2/mods-enabled/cgid.conf',
	  command => 'a2enmod cgid',
  }
  file { '/etc/apache2/ports.conf':
    source => "puppet:///modules/${module_name}/apache2/ports.conf",
  }
}
