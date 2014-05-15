class softecscripts {

  include php5::cli
  include softecscripts::logrotate

  File {
    owner => root,
    group => admin,
    mode  => 775,
  }

  file { '/usr/local/lib/bash':
    ensure      => directory,
    mode        => 02775,
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

  file { '/var/local/log':
    ensure  => directory,
    mode    => 02775,
    group   => super,
    require => Group['super'],
  }

  # richiede readlink, sendmail, flock
  file { '/usr/local/lib/bash/softec-common.sh':
    source  => 'puppet:///modules/softecscripts/lib/bash/softec-common.sh',
    require => File['/usr/local/lib/bash'],
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

  file { '/usr/local/bin/smartfind':
    source  => 'puppet:///modules/softecscripts/bin/smartfind',
    require => Class['php5::cli'],
  }

  file { '/usr/local/bin/smartdu':
    source  => 'puppet:///modules/softecscripts/bin/smartdu',
    require => Class['php5::cli'],
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

  file { '/usr/local/bin/root_device':
    source  => 'puppet:///modules/softecscripts/bin/root_device',
    require => File['/usr/local/lib/bash'],
  }
}
