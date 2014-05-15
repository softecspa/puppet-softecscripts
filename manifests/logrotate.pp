class softecscripts::logrotate {

  logrotate::file { 'softecscripts':
    log          => '/var/local/log/*.log',
    interval     => 'weekly',
    rotation     => '12',
    options      => [ 'missingok', 'compress', 'notifempty' ],
    archive      => true,
    olddir       => '/var/local/log/archives/softecscripts',
    olddir_owner => 'root',
    olddir_group => 'super',
    olddir_mode  => '664',
    create       => '664 root super',
  }
}
