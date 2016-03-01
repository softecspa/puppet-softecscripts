# Pushes commonly used scripts in bash, PHP, Python
# used by OPS department
#
# TODO: clear-cache-wsdl is not so commonly used, find a better place!
#
class softecscripts (
  $logs_owner           = 'root',
  $logs_group           = 'adm',
  $logs_mode            = '2750',
){

  ensure_resource('group', $logs_group, { 'ensure' => 'present' })

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
    mode   => '2775',
  }

  file { '/usr/local/lib/softec-python':
  ensure    => directory,
    source  => 'puppet:///modules/softecscripts/lib/softec-python',
    mode    => '0775',
    recurse => true,
    ignore  => '.svn',
  }

  file { '/var/local/log':
    ensure  => directory,
    owner   => $logs_owner,
    mode    => $logs_mode,
    group   => $logs_group,
    require => Group[$logs_group],
  }

  # requires readlink, sendmail, flock
  file { '/usr/local/lib/bash/softec-common.sh':
    source  => 'puppet:///modules/softecscripts/lib/bash/softec-common.sh',
    require => File['/usr/local/lib/bash'],
  }

  # sourced from softec_private module on our private gitlab
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
    mode   => '0755',
  }->
  file { '/etc/cron.daily/purge-old-kernels':
    ensure => present,
    target => '/usr/local/sbin/purge-old-kernels',
  }

  file { '/usr/local/sbin/user-crontab-finder':
    source => 'puppet:///modules/softecscripts/sbin/user-crontab-finder',
    mode   => '0755',
  }->
  file { '/etc/cron.weekly/user-crontab-finder':
    ensure => absent,
    target => '/usr/local/sbin/user-crontab-finder',
  }

  if $::lsbdistrelease >= 12 {
    # minio utility
    # only on updated systems, wget::fetch on https url fails on Lucid
    wget::fetch { "https://dl.minio.io/client/mc/release/linux-${::architecture}/mc":
      destination => '/usr/local/bin/',
      cache_dir   => '/var/cache/wget',
      verbose     => false,
    }
  }
}
