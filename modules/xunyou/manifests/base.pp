#copyright 
#2014-11
#设置基本的时区，主机名，apt-get源,grub等,sysctl


class xunyou::base(
    $timeserver='59.151.39.244'
){
package {
    ["nload","fping","augeas-tools","vnstat","ruby","htop","mtr","ntpdate","gnupg","screen","curl","tzdata","subversion"]:
    ensure => installed;
}

package {
    ["ntp"]:
    ensure => absent;
}
File{
	mode => "644",
}
file {
	
    "/etc/timezone":
        content => "Asia/Shanghai\n";
    "/etc/cron.d/ntpdate":
        content => "0 8 * * * root  /usr/sbin/ntpdate $timeserver\n";
    "/etc/apt/sources.list":
        source => "puppet:///modules/${module_name}/base/sources.list.${operatingsystemrelease}";

    "/root/.vimrc":
        content => "set background=dark\n";

    "/etc/sysctl.conf":
        source => "puppet:///modules/${module_name}/base/sysctl.conf";
	
    "/etc/security/limits.conf":
        source => "puppet:///modules/${module_name}/base/limits.conf";

    "/etc/bash.bashrc":
        source => "puppet:///modules/${module_name}/base/bash.bashrc";
}

case $webver {
    10:{
    host{
        "chargeserver.xunyou.com":
            ip=>"59.151.39.228",
            ensure => present;
        "mysql.lamyu.com":
            ip=>"112.125.90.37",
            ensure => present;
        }
    } 
    20:{
    host{
        "chargeserver.xunyou.com":
            ip=>"59.151.39.228",
            ensure => present;
        "mysql.lamyu.com":
            ip=>"112.125.90.37",
            ensure => present;
        "redis.xunyou.com":
            ip=>"192.168.4.27",
            ensure =>present;
         }
    } 
    30:{
    host{
        "chargeserver.xunyou.com":
            ip=>"59.151.39.228",
            ensure => present;
        "mysql.lamyu.com":
            ip=>"112.125.90.37",
            ensure => present;
        "redis.xunyou.com":
            ip=>"192.168.4.203",
            ensure =>present;
        }
    } 
    default:{
    host{
        "chargeserver.xunyou.com":
            ip=>"59.151.39.228",
            ensure => present;
        "mysql.lamyu.com":
            ip=>"112.125.90.37",
            ensure => present;
        }
    } 

}

exec {
	"update sorcelist":
	subscribe => File["/etc/apt/sources.list"],
	command => "apt-get update";
	"update timezone":
	subscribe   => File["/etc/timezone"],
	command     => "dpkg-reconfigure --frontend noninteractive tzdata";
	"update sysctl":
	subscribe   => File["/etc/sysctl.conf"],
	command     => "sysctl -p|true";
	}
}
