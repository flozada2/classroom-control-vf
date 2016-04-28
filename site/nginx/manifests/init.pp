#
class nginx (
  $root = undef,
) {

  case $::osfamily {
    'redhat','debian': {
      $package         = 'nginx'
      $owner           = 'root'
      $group           = 'root'
      $default_docroot = '/var/www'
      $confdir         = '/etc/nginx'
      $logdir          = '/var/log/nginx'
    }
    'windows': {
      $package         = 'nginx-service'
      $owner           = 'Administrator'
      $group           = 'Administrators'
      $default_docroot = 'c:/ProgramData/nginx/html'
      $confdir         = 'c:/ProgramData/nginx'
      $logdir          = 'c:/ProgramData/nginx/logs'
    }
    default: {
      fail("${::osfamily} is not supported by this module")
    }
  }
  $svc = 'nginx'
  $source_base = "puppet:///modules/${module_name}"
  $nginx_user = $::osfamily ? {
    'redhat'  => 'nginx',
    'debian'  => 'www-data',
    'windows' => 'nobody',
  }
  $docroot = $root ? {
    undef   => $default_docroot,
    default => $root,
  }

  File {
    ensure => file,
    owner  => $owner,
    group  => $group,
    mode   => '0644',
  }

  # PACKAGE
  package { $package:
    ensure => present,
  }

  # DOCROOT
  file { $docroot:
    ensure => directory,
  }

  # WEB PAGE
  file { "${docroot}/index.html":
    source => "${source_base}/index.html",
  }

  # CONFIG FILES
  file { "${confdir}/nginx.conf":
    #source  => "${source_base}/nginx.conf",
    content => template('nginx/nginx.conf.erb'),
    require => Package[$package],
    notify  => Service[$svc],
  }

  file { "${confdir}/conf.d/default.conf":
    #source  => "${source_base}/default.conf",
    content => template('nginx/default.conf.erb'),
    require => Package[$package],
    notify  => Service[$svc],
  }

  # SERVICE
  service { $svc:
    ensure => running,
    enable => true,
  }

}
