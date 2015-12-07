class softecscripts (
  $logdir_owner           = 'root',
  $logdir_group           = 'adm',
  $logdir_mode            = '2750',
  $logrotate_olddir_owner = 'root',
  $logrotate_olddir_group = 'adm',
  $logrotate_olddir_mode  = '0750',
  $logrotate_create_owner = 'root',
  $logrotate_create_group = 'adm',
  $logrotate_create_mode  = '0664'
){

  # 06/02/2015 l.cocchi: proviamo a togliere il pinning dal PHP 
  #  era `include softec_php::cli`
  apt::ppa { 'ppa:ondrej/php5-oldstable': }
  include php
  include php::cli
  include softecscripts::logrotate

  File {
    owner => root,
    group => admin,
    mode  => 775,
  }

  file { '/usr/local/lib/bash':
    ensure => directory,
    mode   => 02775,
  }

  file { '/usr/local/lib/softec-python':
    source  => 'puppet:///modules/softecscripts/lib/softec-python',
    ensure  => directory,
    mode    => 0775,
    recurse => true,
    ignore  => '.svn',
    owner   => root,
    group   => root,
  }

  $require = $logdir_group ? {
    'adm'   => undef,
    'root'  => undef,
    default => Group[$logdir_group]
  }

  file { '/var/local/log':
    ensure  => directory,
    owner   => $logdir_owner,
    mode    => $logdir_mode,
    group   => $logdir_group,
    require => $require,
  }

  # richiede readlink, sendmail, flock
  file { '/usr/local/lib/bash/softec-common.sh':
    source  => 'puppet:///modules/softecscripts/lib/bash/softec-common.sh',
    require => File['/usr/local/lib/bash'],
  }

  file { '/usr/local/etc/slack.conf':
    source => 'puppet:///modules/softec_private/etc/slack.conf',
  }

  file { '/usr/local/bin/sample-bash-script':
    source  => 'puppet:///modules/softecscripts/bin/sample-bash-script',
    require => File['/usr/local/lib/bash/softec-common.sh'],
  }

  file { '/usr/local/bin/file-age':
    source  => 'puppet:///modules/softecscripts/bin/file-age',
    require => File['/usr/local/lib/bash/softec-common.sh'],
  }

  file { '/usr/local/bin/clear-cache-wsdl':
    source  => 'puppet:///modules/softecscripts/bin/clear-cache-wsdl',
    require => File['/usr/local/lib/bash/softec-common.sh'],
  }

  softec_sudo::conf {'softecscripts':
    source => 'puppet:///modules/softecscripts/etc/sudo'
  }

  file { '/usr/local/bin/smartfind':
    source  => 'puppet:///modules/softecscripts/bin/smartfind',
    require => Class['php::cli'],
  }

  file { '/usr/local/bin/smartdu':
    source  => 'puppet:///modules/softecscripts/bin/smartdu',
    require => Class['php::cli'],
  }

  file { '/usr/local/bin/remote-updater':
    source  => 'puppet:///modules/softecscripts/bin/remote-updater',
    require => Package['wget'],
  }

  file { '/usr/local/bin/solo':
    source  => 'puppet:///modules/softecscripts/bin/solo',
    require => Package['perl'],
  }

  file { '/usr/local/bin/nway':
    source  => 'puppet:///modules/softecscripts/bin/nway',
    require => Package['perl'],
  }

  file { '/usr/local/bin/aws':
    source  => 'puppet:///modules/softecscripts/bin/aws',
    require => [ Package['perl'], Package['curl'] ],
  }

  file { '/usr/local/bin/meminfo.pl':
    source  => 'puppet:///modules/softecscripts/bin/meminfo.pl',
    require => Package['perl'],
  }

  file { '/usr/local/sbin/purge-old-kernels':
    source => 'puppet:///modules/softecscripts/sbin/purge-old-kernels',
    mode   => 755,
  }->
  file { '/etc/cron.daily/purge-old-kernels':
    ensure  => present,
    target => '/usr/local/sbin/purge-old-kernels',
  }

}
