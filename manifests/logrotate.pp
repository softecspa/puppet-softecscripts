class softecscripts::logrotate {

  file {'/var/local/log/archives/':
    ensure  => directory,
    owner   => $softecscripts::logs_owner,
    group   => $softecscripts::logs_group,
    mode    => $softecscripts::logs_mode
  }

  logrotate::file { 'softecscripts':
    log          => '/var/local/log/*.log',
    interval     => 'weekly',
    rotation     => '12',
    options      => [ 'missingok', 'compress', 'notifempty' ],
    archive      => true,
    olddir       => '/var/local/log/archives/softecscripts',
    create       => "${softecscripts::logs_mode} ${softecscripts::logs_owner} ${softecscripts::logs_group}",
    require       => File['/var/local/log/archives/'],
  }
}
