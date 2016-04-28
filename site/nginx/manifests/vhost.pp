define nginx::vhost (
$port = '80',
$servername = $title,
$docroot = "${nginx::docroot}/vhosts/${title}",
) {
File {
owner => $nginx::owner,
group => $nginx::group,
mode => '0664',
}
# Hack to work around lack of DNS. Not for production use!
host { $title:
ip => $::ipaddress,
}
file { "nginx-vhost-${title}":
ensure => file,
path => "${nginx::confdir}/conf.d/${title}.conf",
content => template('nginx/vhost.conf.erb'),
notify => Service['nginx'],
}
file { $docroot:
ensure => directory,
before => File["nginx-vhost-${title}"],
}
file { "${docroot}/index.html":
ensure => file,
content => template('nginx/index.html.erb'),
}
}
class nginx {
case $::osfamily {
'redhat','debian' : {
$package = 'nginx'
$owner = 'root'
$group = 'root'
$docroot = '/var/www'
$confdir = '/etc/nginx'
$logdir = '/var/log/nginx'
}
'windows' : {
$package = 'nginx-service'
$owner = 'Administrator'
$group = 'Administrators'
$docroot = 'C:/ProgramData/nginx/html'
$confdir = 'C:/ProgramData/nginx'
$logdir = 'C:/ProgramData/nginx/logs'
}
default : {
fail("Module ${module_name} is not supported on ${::osfamily}")
}
}
# user the service will run as. Used in the nginx.conf.erb template
$user = $::osfamily ? {
'redhat' => 'nginx',
'debian' => 'www-data',
'windows' => 'nobody',
}
File {
owner => $owner,
group => $group,
mode => '0664',
}
package { $package:
ensure => present,
}
file { [ "${docroot}/vhosts", "${confdir}/conf.d" ]:
ensure => directory,
}
# manage the default docroot, index, and conf--replaces several resources
nginx::vhost { 'default':
docroot => $docroot,
servername => $::fqdn,
}
file { "${confdir}/nginx.conf":
ensure => file,
content => template('nginx/nginx.conf.erb'),
notify => Service['nginx'],
}
service { 'nginx':
ensure => running,
enable => true,
}
}
